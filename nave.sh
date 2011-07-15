#!/bin/bash

# This program contains parts of narwhal's "sea" program,
# as well as bits borrowed from Tim Caswell's "nvm"

# nave install <version>
# Fetch the version of node and install it in nave's folder.

# nave use <version>
# Install the <version> if it isn't already, and then start
# a subshell with that version's folder at the start of the
# $PATH

# nave use <version> program.js
# Like "nave use", but have the subshell start the program.js
# immediately.

# When told to use a version:
# Ensure that the version exists, install it, and
# then add its prefix to the PATH, and start a subshell.

if [ "$NAVE_DEBUG" != "" ]; then
  set -x
fi

tar=${TAR-tar}

main () {
  local SELF_PATH DIR SYM
  # get the absolute path of the executable
  SELF_PATH="$0"
  if [ "${SELF_PATH:0:1}" != "." ] && [ "${SELF_PATH:0:1}" != "/" ]; then
    SELF_PATH=./"$SELF_PATH"
  fi
  SELF_PATH=$( cd -P -- "$(dirname -- "$SELF_PATH")" \
            && pwd -P \
            ) && SELF_PATH=$SELF_PATH/$(basename -- "$0")

  # resolve symlinks
  while [ -h "$SELF_PATH" ]; do
    DIR=$(dirname -- "$SELF_PATH")
    SYM=$(readlink -- "$SELF_PATH")
    SELF_PATH=$( cd -- "$DIR" \
              && cd -- $(dirname -- "$SYM") \
              && pwd \
              )/$(basename -- "$SYM")
  done

  if ! [ -d "$NAVE_DIR" ]; then
    if [ -d "$HOME" ]; then
      NAVE_DIR="$HOME"/.nave
    else
      NAVE_DIR=/usr/local/lib/nave
    fi
  fi
  if ! [ -d "$NAVE_DIR" ] && ! mkdir -p -- "$NAVE_DIR"; then
    NAVE_DIR="$(dirname -- "$SELF_PATH")"
  fi

  export NAVE_DIR
  export NAVE_SRC="$NAVE_DIR/src"
  export NAVE_ROOT="$NAVE_DIR/installed"
  ensure_dir "$NAVE_SRC"
  ensure_dir "$NAVE_ROOT"

  local cmd="$1"
  shift
  case $cmd in
    ls-remote | ls-all)
      cmd="nave_${cmd/-/_}"
      ;;
#    use)
#      cmd="nave_named"
#      ;;
    install | fetch | use | clean | test | named | \
    ls |  uninstall | usemain | latest | stable )
      cmd="nave_$cmd"
      ;;
    * )
      cmd="nave_help"
      ;;
  esac
  $cmd "$@" && exit 0 || fail "failed somehow"
}

function enquote_all () {
  local ARG ARGS
  ARGS=""
  for ARG in "$@"; do
    [ -n "$ARGS" ] && ARGS="$ARGS "
    ARGS="$ARGS'""$( echo " $ARG" \
                   | cut -c 2- \
                   | sed 's/'"'"'/'"'"'"'"'"'"'"'"'/g' \
                   )""'"
  done
  echo "$ARGS"
}

ensure_dir () {
  if ! [ -d "$1" ]; then
    mkdir -p -- "$1" || fail "couldn't create $1"
  fi
}
remove_dir () {
  if [ -d "$1" ]; then
    rm -rf -- "$1" || fail "Could not remove $1"
  fi
}

fail () {
  echo "$@" >&2
  exit 1
}

nave_fetch () {
  local version=$(ver "$1")
  if nave_has "$version"; then
    echo "already fetched $version" >&2
    return 0
  fi

  local src="$NAVE_SRC/$version"
  remove_dir "$src"
  ensure_dir "$src"

  # fixme: use array here.
  local url="http://nodejs.org/dist/node-v$version.tar.gz"
  local url2="http://nodejs.org/dist/v$version/node-v$version.tar.gz"
  local url3="http://nodejs.org/dist/node-$version.tar.gz"
  curl -# -L "$url" \
    | $tar xzf - -C "$src" --strip-components=1 \
    || curl -# -L "$url2" \
      | $tar xzf - -C "$src" --strip-components=1 \
      || curl -# -L "$url3" \
        | $tar xzf - -C "$src" --strip-components=1 \
        || fail "Couldn't fetch $version"

  return 0
}

nave_usemain () {
  if [ ${NAVELVL-0} -gt 0 ]; then
    fail "Can't usemain inside a nave subshell. Exit to main shell."
  fi
  local version=$(ver "$1")
  local current=$(node -v || true)
  local wn=$(which node || true)
  local prefix="/usr/local"
  if [ "x$wn" != "x" ]; then
    prefix="${wn/\/bin\/node/}"
    if [ "x$prefix" == "x" ]; then
      prefix="/usr/local"
    fi
  fi
  current="${current/v/}"
  if [ "$current" == "$version" ]; then
    echo "$version already installed"
    return 0
  fi
  nave_fetch "$version"
  src="$NAVE_SRC/$version"

  ( cd -- "$src"
    JOBS=${JOBS:-8} ./configure --debug --prefix $prefix \
      || fail "Failed to configure $version"
    JOBS=${JOBS:-8} make \
      || fail "Failed to make $version in main env"
    make install || fail "Failed to install $version in main env"
  ) || fail "fail"
}

nave_install () {
  local version=$(ver "$1")
  if nave_installed "$version"; then
    echo "Already installed: $version" >&2
    return 0
  fi
  nave_fetch "$version"

  local src="$NAVE_SRC/$version"
  local install="$NAVE_ROOT/$version"
  remove_dir "$install"
  ensure_dir "$install"
  ( cd -- "$src"
    JOBS=${JOBS:-8} ./configure --debug --prefix="$install" \
      || fail "Failed to configure $version"
    JOBS=${JOBS:-8} make \
      || fail "Failed to make $version"
    make install || fail "Failed to install $version"
  ) || fail "fail"
}
nave_test () {
  local version=$(ver "$1")
  nave_fetch "$version"
  local src="$NAVE_SRC/$version"
  ( cd -- "$src"
    ./configure --debug || fail "failed to ./configure --debug"
    make test-all || fail "Failed tests"
  ) || fail "failed"
}

nave_ls () {
  ls -- $NAVE_SRC | version_list "src" \
    && ls -- $NAVE_ROOT | version_list "installed" \
    || return 1
}
nave_ls_remote () {
  curl -s http://nodejs.org/dist/ \
    | version_list "remote" \
    || return 1
}
nave_ls_all () {
  nave_ls \
    && nave_ls_remote \
    || return 1
}
ver () {
  local version="$1"
  version="${version/v/}"
  case $version in
    latest | stable) nave_$version ;;
    *) echo $version ;;
  esac
}
nave_latest () {
  curl -s http://nodejs.org/dist/ \
    | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | tail -n1
}
nave_stable () {
  curl -s http://nodejs.org/dist/ \
    | egrep -o '[0-9]+\.[2468]\.[0-9]+' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | tail -n1
}

version_list () {
  echo "$1:"
  egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | organize_version_list \
    || return 1
}

organize_version_list () {
  local i=0
  local v
  while read v; do
    if [ $i -eq 8 ]; then
      i=0
      echo "$v"
    else
      let 'i = i + 1'
      echo -ne "$v\t"
    fi
  done
  echo ""
  [ $i -ne 0 ] && echo ""
  return 0
}

nave_has () {
  local version=$(ver "$1")
  [ -d "$NAVE_SRC/$version" ] || return 1
}
nave_installed () {
  local version=$(ver "$1")
  [ -d "$NAVE_ROOT/$version/bin" ] || return 1
}

nave_use () {
  local version=$(ver "$1")
  if [ -z "$version" ]; then
    fail "Must supply a version"
  fi
  nave_install "$version" || fail "failed to install $version"
  local bin="$NAVE_ROOT/$version/bin"
  local lib="$NAVE_ROOT/$version/lib/node"
  local man="$NAVE_ROOT/$version/share/man"
  if [ "$version" == "$NAVE" ]; then
    echo "already using $NAVE"
    if [ $# -gt 1 ]; then
      shift
      node "$@"
    fi
    return $?
  fi
  local lvl=$[ ${NAVELVL-0} + 1 ]
  echo "using $version"
  if [ $# -gt 1 ]; then
    shift
    hash -r
    PATH="$bin:$PATH" NAVELVL=$lvl NAVE="$version" \
      NAVEVERSION="$version" \
      npm_config_binroot="$bin" npm_config_root="$lib" \
      npm_config_manroot="$man" \
      NODE_PATH="$lib" \
      "$SHELL" -c "$(enquote_all node "$@")"
    hash -r
  else
    hash -r
    PATH="$bin:$PATH" NAVELVL=$lvl NAVE="$version" \
      NAVEVERSION="$version" \
      npm_config_binroot="$bin" npm_config_root="$lib" \
      npm_config_manroot="$man" \
      NODE_PATH="$lib" \
      "$SHELL"
    hash -r
  fi
  return $?
}

nave_named () {
  local name="$1"
  shift
  if [ "$name" == "$NAVE" ]; then
    echo "already using $name"
    if [ $# -gt 0 ]; then
      node "$@"
    fi
    return $?
  fi
  if ! [ -d "$NAVE_ROOT/$name" ]; then
    add_named_env "$name" || fail "failed to create $name env"
  fi
  local bin="$NAVE_ROOT/$name/bin"
  local npmbin="$NAVE_ROOT/$name/npm-bin"
  local lib="$NAVE_ROOT/$name/lib/node"
  local man="$NAVE_ROOT/$name/share/man"
  ensure_dir bin
  ensure_dir npmbin
  ensure_dir lib
  ensure_dir man
  local version
  if [ -L "$bin" ]; then
    version="$(ls -laF -- "$bin" | egrep -o '[^/]+/bin$' | cut -d / -f 1)"
  else
    version="$name"
  fi
  local lvl=$[ ${NAVELVL-0} + 1 ]
  # get the version
  if [ $# -gt 0 ]; then
    PATH="$bin:$npmbin:$PATH" \
      NAVELVL=$lvl \
      NAVE="$name" \
      NAVEVERSION="$version" \
      NAVENAME="$name" \
      npm_config_binroot="$npmbin" \
      npm_config_root="$lib" \
      npm_config_manroot="$man" \
      NODE_PATH="$lib" \
      "$SHELL" -c "$(enquote_all node "$@")"
  else
    echo "setting path to $bin:$npmbin:$PATH"
    PATH="$bin:$npmbin:$PATH" \
      NAVELVL=$lvl \
      NAVE="$name" \
      NAVEVERSION="$version" \
      NAVENAME="$name" \
      npm_config_binroot="$npmbin" \
      npm_config_root="$lib" \
      npm_config_manroot="$man" \
      NODE_PATH="$lib" \
      "$SHELL"
  fi
  return $?
}

add_named_env () {
  local name="$1"
  echo "Creating new env named '$name'"
  echo "What version of node?"
  local version
  read -p "x.y.z > " version
  nave_install "$version" || fail "failed to install $version"
  ensure_dir -p -- "$NAVE_ROOT/$name/lib/node"
  ensure_dir -p -- "$NAVE_ROOT/$name/share/man"
  ln -s -- "$NAVE_ROOT/$version/bin" "$NAVE_ROOT/$name/bin"
}


nave_clean () {
  remove_dir "$NAVE_SRC/$(ver "$1")"
}
nave_uninstall () {
  remove_dir "$NAVE_ROOT/$(ver "$1")"
}

nave_help () {
  cat <<EOF

Usage: nave <cmd>

Commands:

  install <version>    Install the version passed (ex: 0.1.103)
  use <version>        Enter a subshell where <version> is being used
  use <ver> <program>  Enter a subshell, and run "node <program>", then exit
  usemain <version>    Install in /usr/local/bin (ie, use as your main nodejs)
  clean <version>      Delete the source code for <version>
  uninstall <version>  Delete the install for <version>
  ls                   List versions currently installed
  ls-remote            List remote node versions
  ls-all               List remote and local node versions
  latest               Show the most recent dist version
  help                 Output help information

<version> can be the string "latest" to get the latest distribution.
<version> can be the string "stable" to get the latest stable version.

EOF
}

main "$@"
