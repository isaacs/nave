#!/bin/bash

# This program contains parts of narwhal's "sea" program,
# as well as bits borrowed from Tim Caswell's "nvm"

# nave install <version>
# Fetch the version of node and install it in nave's folder.

# nave use <version>
# Install the <version> if it isn't already, and then start
# a subshell with that version's folder at the start of the
# $PATH

# nave --version <version> program.js
# Like "nave use", but have the subshell start the program.js
# immediately.

# When told to use a version:
# Ensure that the version exists, install it, and
# then add its prefix to the PATH, and start a subshell.

tar=${TAR-tar}

main () {
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

  export NAVE_SRC="$(dirname -- "$SELF_PATH")/src"
  export NAVE_ROOT="$(dirname -- "$SELF_PATH")/installed"
  ensure_dir "$NAVE_SRC"
  ensure_dir "$NAVE_ROOT"

  local cmd="$1"
  shift
  case $cmd in
    ls-remote | ls-all)
      cmd="nave_${cmd/-/_}"
      ;;
    install | fetch | use | clean | test | ls | uninstall | usemain | latest )
      cmd="nave_$cmd"
      ;;
    * )
      cmd="nave_help"
      ;;
  esac
  $cmd "$@" && exit 0 || fail "failed somehow"
}

function enquote_all () {
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
  version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  if nave_has "$version"; then
    echo "already fetched $version" >&2
    return 0
  fi

  src="$NAVE_SRC/$version"
  remove_dir "$src"
  ensure_dir "$src"
  url="http://nodejs.org/dist/node-v$version.tar.gz"
  url2="http://nodejs.org/dist/node-$version.tar.gz"
  curl -# -L "$url" \
    | $tar xzf - -C "$src" --strip-components=1 \
    || curl -# -L "$url2" \
      | $tar xzf - -C "$src" --strip-components=1 \
      || fail "Couldn't fetch $version"
  return 0
}

nave_usemain () {
  local version="$1"
  local current=$(node -v || true)
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  current="${current/v/}"
  if [ "$current" == "$version" ]; then
    echo "$version already installed"
    return 0
  fi
  nave_fetch "$version"
  src="$NAVE_SRC/$version"
  ( cd -- "$src"
    JOBS=8 ./configure || fail "Failed to configure $version"
    JOBS=8 make || fail "Failed to make $version in main env"
    make install || fail "Failed to install $version in main env"
  ) || fail "fail"
}

nave_install () {
  local version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi

  if nave_installed "$version"; then
    echo "Already installed: $version" >&2
    return 0
  fi
  nave_fetch "$version"

  src="$NAVE_SRC/$version"
  install="$NAVE_ROOT/$version"
  remove_dir "$install"
  ensure_dir "$install"
  ( cd -- "$src"
    JOBS=8 ./configure --prefix="$install" || fail "Failed to configure $version"
    JOBS=8 make || fail "Failed to make $version"
    make install || fail "Failed to install $version"
  ) || fail "fail"
}
nave_test () {
  version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  nave_fetch "$version"
  src="$NAVE_SRC/$version"
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
nave_latest () {
  curl -s http://nodejs.org/dist/ \
    | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
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
  version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  [ -d "$NAVE_SRC/$version" ] || return 1
}
nave_installed () {
  version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  [ -d "$NAVE_ROOT/$version/bin" ] || return 1
}

nave_use () {
  local version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  nave_install "$version" || fail "failed to install $version"
  bin="$NAVE_ROOT/$version/bin"
  if [ "$version" == "$NAVE" ]; then
    echo "already using $NAVE"
    if [ $# -gt 1 ]; then
      shift
      node "$@"
    fi
    return
  fi
  lvl=$[ ${NAVELVL-0} + 1 ]
  echo "using $version"
  if [ $# -gt 1 ]; then
    shift
    PATH="$bin:$PATH" NAVELVL=$lvl NAVE="$version" "$SHELL" -c "$(enquote_all node "$@")"
  else
    PATH="$bin:$PATH" NAVELVL=$lvl NAVE="$version" "$SHELL"
  fi
}

nave_clean () {
  version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  remove_dir "$NAVE_SRC/$version"
}
nave_uninstall () {
  version="$1"
  version="${version/v/}"
  if [ "$version" == "latest" ]; then
    version=$(nave_latest)
  fi
  remove_dir "$NAVE_ROOT/$version"
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

<version> can also be the string "latest" to get the latest distribution.

EOF
}

main "$@"
