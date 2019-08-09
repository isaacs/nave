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

if [ -z "$BASH" ]; then
  cat >&2 <<MSG
Nave is a bash program, and must be run with bash.
MSG
  exit 1
fi

# Use fancy pants globs
shopt -s extglob

# Try to figure out the os and arch for binary fetching
osarch () {
  local uname=$(uname -a)
  local os=
  local arch=
  case "$uname" in
    Linux\ *) os=linux ;;
    Darwin\ *) os=darwin ;;
    SunOS\ *) os=sunos ;;
  esac
  case "$uname" in
    *x86_64*) arch=x64 ;;
    *i[3456]86*) arch=x86 ;;
    *raspberrypi*) arch=arm-pi ;;
  esac
  # memoize
  if [ "$os" != "" ] && [ "$arch" != "" ]; then
    eval 'osarch () { echo "'$os-$arch'"; };'
    echo "$os-$arch"
  else
    eval 'osarch () { return 1; };'
    return 1
  fi
}

tar=${TAR-tar}

main () {
  get_nave_dir
  write_rcfile

  export NAVE_DIR
  mkdirp "$NAVE_SRC"
  mkdirp "$NAVE_ROOT"

  local cmd="$1"
  shift
  case $cmd in
    ls-remote | ls-all)
      cmd="nave_${cmd/-/_}"
      ;;
    auto|cache|exit|install|fetch|use|clean|test|named|ls|uninstall|usemain|latest|stable|lts|has|installed|get)
      cmd="nave_$cmd"
      ;;
    * )
      cmd="nave_help"
      ;;
  esac
  # err "nave_$cmd = [$cmd] @=[$@]"
  $cmd "$@"
}

get_nave_dir () {
  NODEDIST=${NODEDIST:-https://nodejs.org/dist}
  NAVE_CACHE_DUR=${NAVE_CACHE_DUR:-86400}
  NAVEUA="nave/$(curl --version | head -n1)"

  if [ -z "${NAVE_DIR+defined}" ]; then
    if [ -d "$XDG_CONFIG_HOME" ] && ! [ -d "$HOME/.nave" ]; then
      NAVE_DIR="$XDG_CONFIG_HOME"/nave
    elif [ -d "$HOME" ]; then
      NAVE_DIR="$HOME"/.nave
    else
      local prefix=${PREFIX:-/usr/local}
      NAVE_DIR=$prefix/lib/nave
    fi
  fi
  NAVE_SRC="$NAVE_DIR/src"
  NAVE_ROOT="$NAVE_DIR/installed"
}

nave_get () {
  case "$1" in
    root) echo $NAVE_ROOT ;;
    cache) echo $NAVE_DIR/cache ;;
    dir) echo $NAVE_DIR  ;;
    src) echo $NAVE_SRC  ;;
    cache-dur) echo $NAVE_CACHE_DUR ;;
    ua) echo $NAVEUA ;;
    src-only) echo $NAVE_SRC_ONLY ;;
    *)
      if [ "$1" != "" ]; then
        err "unknown setting: $1"
      fi
      cat <<USAGE
Usage:
  nave get (root|cache|dir|src|cache-dur|ua|src-only)
USAGE
;;
  esac
}

enquote_all () {
  local ARG ARGS
  ARGS=()
  for ARG in "$@"; do
    # start each arg with a ', then replace all ' with '"'"', then end quote
    # so "o'brien" becomes 'o'"'"'brien'
    # it's a bit line noisey, but it works reliably.
    local newArg="$(echo "$ARG" | sed 's/'"'"'/'"'"'"'"'"'"'"'"'/g')"
    ARGS+=("'$newArg'")
  done
  echo "${ARGS[@]}"
}

mkdirp () {
  local defaultMsg="couldn't create $1"
  msg=${2:-$defaultMsg}
  mkdir -p -- "$1" || fail "$msg"
}

rimraf () {
  rm -rf -- "$1" || fail "Could not remove $1"
}

err () {
  echo "$@" >&2
}

fail () {
  err "$@"
  [ -z $_TESTING_NAVE_NO_EXIT ] && exit 1
}

nave_fetch () {
  local version=$(ver "$1")
  if nave_has "$version"; then
    return 0
  fi

  local src="$NAVE_SRC/$version"
  rimraf "$src"
  mkdirp "$src"

  local tarfile
  tarfile="$(get "v$version/node-v$version.tar.gz" -#Lf)"
  if [ $? -eq 0 ]; then
    cp "$tarfile" "$src".tgz
    $tar xzf "$src".tgz -C "$src" --strip-components=1
    if [ $? -eq 0 ]; then
      err "fetched $version"
      return 0
    fi
  fi

  rm "$src".tgz
  rimraf "$src"
  err "Couldn't fetch $version"
  return 1
}

get_shasum () {
  local dir=$1
  local base=$2
  get_html "$dir/SHASUMS256.txt" | grep "$base" | awk '{print $1}'
}

get_tgz () {
  local path=$1
  local base=$(basename "$path")
  local dir=$(dirname "$path")
  shift

  local shasum=$(get_shasum "$dir" "$base")

  local cache=$NAVE_DIR/cache
  if [ "$shasum" == "" ]; then
    # this should not happen, blow away cache and try 1 more time
    rm -- "$cache/$dir/SHASUMS256.txt"* || true
    shasum=$(get_shasum "$dir" "$base")
  fi

  if [ "$shasum" == "" ]; then
    err "shasum not found for $base. aborting download."
    return 2
  fi

  if [ -f "$cache/$dir/$shasum.tgz" ]; then
    echo "$cache/$dir/$shasum.tgz"
    return
  fi

  get_ "$NODEDIST/$path" "$@" > "$cache/$dir/$base"
  if [ $? -ne 0 ]; then
    rm "$cache/$dir/$base"
    return 2
  fi

  local actualshasum=$(shasum -a 256 "$cache/$dir/$base" | awk '{print $1}')
  if ! [ "$shasum" = "$actualshasum" ]; then
    err "shasum mismatch, expect $shasum, got $actualshasum"
    rm "$cache/$dir/$base"
    return 2
  fi

  mv "$cache/$dir/$base" "$cache/$dir/$shasum.tgz"
  echo "$cache/$dir/$shasum.tgz"
}

get_timestamp () {
  local file=$1
  local n=$(cat $file 2>/dev/null)
  local numre='^[0-9]+$'
  if [ -n "$n" ] && [[ $n =~ $numre ]]; then
    echo $n
  else
    echo 0
  fi
}

get_html () {
  local path=$1
  local base=$(basename "$path")
  local dir=$(dirname "$path")
  shift

  if [ "$dir" = "/" ]; then
    dir=""
  fi
  if [ "$base" = "/" ]; then
    base=""
  fi
  if [ "$base" = "" ]; then
    base="index.html"
  fi

  local cache="$NAVE_DIR/cache/$dir"
  mkdirp "$cache"
  local tsfile="$cache/${base}-timestamp"

  local dur=$NAVE_CACHE_DUR
  if ! [ "$cache/$base" = "$cache/index.html" ]; then
    dur=$[ $dur * 365 ]
  fi

  if [ -f "$tsfile" ] && \
     [ -f "$cache/$base" ] && \
     [ $[ $(date '+%s') - $(get_timestamp $tsfile) ] -lt $dur ]; then
    cat "$cache/$base"
  else
    get_ "$NODEDIST/$path" -s "$@" > "$cache/${base}.tmp"
    local ret=$?
    if [ "$ret" -ne 0 ]; then
      rm "$cache/${base}.tmp"
      ret=2
      if [ -f "$cache/$base" ]; then
        cat "$cache/$base"
        ret=$cacheret
      fi
    else
      mv "$cache/${base}.tmp" "$cache/$base"
      date '+%s' > "$tsfile"
      cat "$cache/$base"
    fi
    return $ret
  fi
}

get_ () {
  curl "$@" -H "user-agent:$NAVEUA" || return 2
}

get () {
  local path=$1
  local base=$(basename "$path")
  local dir=$(dirname "$path")
  shift

  case "$base" in
    *.tar.gz|*.tgz)
      get_tgz "$path" "$@"
      ;;
    *)
      get_html "$path" "$@"
      ;;
  esac
}

bin_available () {
  local version="$1"
  if [ "$NAVE_SRC_ONLY" = "1" ]; then
    return 1
  elif osarch >/dev/null; then
    # binaries started with node 0.8.6
    case "$version" in
      0.8.[012345]) return 1 ;;
      0.[01234567].*) return 1 ;;
      *) return 0 ;;
    esac
  else
    return 1
  fi
}

build_binary () {
  local version="$1"
  if ! bin_available "$version"; then
    return 1
  fi
  local targetfolder="$2"
  local t="$version-$(osarch)"
  local url="v$version/node-v${t}.tar.gz"
  # have to do in 2 commands or else the "local" returns 0!
  local tarfile
  tarfile=$(get "$url" -#Lf)
  local ret=$?
  if [ $ret -eq 0 ]; then
    # it worked!
    cat "$tarfile" | $tar xz -C "$targetfolder" --strip-components 1
  else
    return $ret
  fi
}

build () {
  local version="$1"
  local targetfolder="$2"

  # shortcut - try the binary if possible.
  if bin_available $version; then
    if build_binary "$version" "$targetfolder"; then
      return 0
    else
      nave_uninstall "$version"
      err "Binary install failed, trying source."
    fi
  fi

  if ! nave_fetch "$version"; then
    # fetch failed, don't continue and try to build it.
    return 1
  fi

  local src="$NAVE_SRC/$version"
  local jobs=$NAVE_JOBS
  jobs=${jobs:-$JOBS}
  jobs=${jobs:-$(sysctl -n hw.ncpu)}
  jobs=${jobs:-2}

  ( cd -- "$src" &>/dev/null
    source_naverc
    if [ "$NAVE_CONFIG" == "" ]; then
      NAVE_CONFIG=()
    fi
    if ! JOBS=$jobs ./configure "${NAVE_CONFIG[@]}" --prefix="$2"; then
      err "Failed to configure $version"
      return 1
    fi
    if ! JOBS=$jobs make -j$jobs; then
      err "Failed to make $version"
      return 1
    fi
    if ! make install; then
      err "Failed to install $version"
      return 1
    fi
  )
}

nave_cache () {
  local cache="$NAVE_DIR/cache"
  local subcmd="$1"
  shift
  mkdirp "$cache"
  case "$subcmd" in
    clear|empty|clean)
      rm -rf "$cache"
      ;;
    ls)
      find "$cache" "$@"
      ;;
    tree)
      tree "$cache" "$@"
      ;;
    *)
      cat >&2 <<USAGE
usage: nave cache [clear|ls|tree]
USAGE
      return 1
      ;;
  esac
}

# Run this on cd'ing into new directories to automatically enter that
# nave setting in that directory.
nave_auto () {
  if [ $# -gt 0 ]; then
    cd $1
    if [ $? -ne 0 ]; then
      exec $SHELL
    fi
    shift
  fi

  local dir=$(pwd)
  while ! [ "$dir" = "/" ]; do
    if [ -f "$dir"/.naverc ]; then
      local args=($(cat "$dir"/.naverc))
      if [ "$#" -eq 0 ]; then
        nave_use "${args[@]}" exec $SHELL
      else
        nave_use "${args[@]}" $SHELL -c "$(enquote_all "$@")"
      fi
      return $?
    elif [ -d "$dir"/.git ]; then
      break
    else
      dir=$(dirname -- "$dir")
    fi
  done
  nave_exit
}

nave_usemain () {
  if [ ${NAVELVL-0} -gt 0 ]; then
    err "Can't usemain inside a nave subshell. Exit to main shell."
    return 1
  fi
  local version=$(ver "$1")
  local current=$(node -v 2>/dev/null)
  local wn=$(which node)
  local prefix=${PREFIX:-/usr/local}
  if [ -x "$wn" ] && [[ "$current" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    local p="${wn/\/bin\/node/}"
    if [ "$p" != "" ] && [ -d "$prefix" ]; then
      prefix=$p
    fi
  fi
  current="${current/v/}"
  if [ "$current" == "$version" ]; then
    return 0
  fi

  build "$version" "$prefix"
}

nave_install () {
  if [ $# -eq 2 ]; then
    add_named_env "$1" "$2"
    return $?
  fi

  local version=$(ver "$1" "NONAMES")
  if [ -z "$version" ]; then
    err "Must supply a version ('lts', 'stable', 'latest' or numeric)"
    return 1
  fi
  if nave_installed "$version"; then
    return 0
  fi
  local install="$NAVE_ROOT/$version"
  mkdirp "$install"

  build "$version" "$install"
  local ret=$?
  if [ $ret -ne 0 ]; then
    rimraf "$install"
    return $ret
  fi
}

nave_exit () {
  if [ -n "$NAVEPATH" ]; then
    export PATH=${PATH:${#NAVEPATH}+1}
  fi
  unset NAVEDEBUG
  unset NAVE_JOBS
  unset NAVELVL
  unset NAVEPATH
  unset NAVEVERSION
  unset NAVENAME
  unset NAVE
  unset NAVE_SRC
  unset NAVE_CONFIG
  unset NAVE_ROOT
  unset NODE_PATH
  unset NAVE_LOGIN
  unset NAVE_DIR
  unset ZDOTDIR
  unset npm_config_binroot
  unset npm_config_root
  unset npm_config_manroot
  unset npm_config_prefix
  exec $SHELL
}

naverc_filename () {
  echo $(cd -- $NAVE_DIR/.. &>/dev/null; pwd)/.naverc
}

source_naverc () {
  local naverc=$(naverc_filename)
  if [ -f "$naverc" ]; then
    . "$naverc"
  fi
}

write_rcfile () {
  mkdirp "$NAVE_DIR" "could not make NAVE_DIR ($NAVE_DIR)"

  # set up the naverc init file.
  # For zsh compatibility, we name this file ".zshenv" instead of
  # the more reasonable "naverc" name.
  # Important! Update this number any time the init content is changed.
  local rcversion="#4"
  local rcfile="$NAVE_DIR/.zshenv"
  if ! [ -f "$rcfile" ] \
      || [ "$(head -n1 "$rcfile")" != "$rcversion" ]; then

    local homercfile=$(naverc_filename)
    cat > "$rcfile" <<RC
$rcversion
[ "\$NAVE_DEBUG" != "" ] && set -x || true
if [ "\$BASH" != "" ]; then
  if [ "\$NAVE_LOGIN" != "" ]; then
    [ -f ~/.bash_profile ] && . ~/.bash_profile || true
    [ -f ~/.bash_login ] && .  ~/.bash_login || true
    [ -f ~/.profile ] && . ~/.profile || true
  else
    [ -f ~/.bashrc ] && . ~/.bashrc || true
  fi
else
  [ -f ~/.zshenv ] && . ~/.zshenv || true
  export DISABLE_AUTO_UPDATE=true
  if [ "\$NAVE_LOGIN" != "" ]; then
    [ -f ~/.zprofile ] && . ~/.zprofile || true
    [ -f ~/.zshrc ] && . ~/.zshrc || true
    [ -f ~/.zlogin ] && . ~/.zlogin || true
  else
    [ -f ~/.zshrc ] && . ~/.zshrc || true
  fi
fi
unset ZDOTDIR
export PATH=\$NAVEPATH:\$PATH
[ -f ${homercfile} ] && . ${homercfile} || true
RC

    cat > "$NAVE_DIR/.zlogout" <<RC
[ -f ~/.zlogout ] && . ~/.zlogout || true
RC

  fi

  # couldn't write file
  if ! [ -f "$rcfile" ] || [ "$(head -n1 "$rcfile")" != "$rcversion" ]; then
    fail "Failed writing rc files to $NAVE_DIR"
  fi
}

nave_test () {
  local version=$(ver "$1")
  nave_fetch "$version"
  local src="$NAVE_SRC/$version"
  ( cd -- "$src"
    source_naverc
    if [ "$NAVE_CONFIG" == "" ]; then
      NAVE_CONFIG=()
    fi
    if ! ./configure "${NAVE_CONFIG[@]}"; then
      err "failed ./configure"
      return 1
    else
      make test-all
    fi
  )
}

nave_ls () {
  ls -- $NAVE_SRC | version_list "src" \
    && ls -- $NAVE_ROOT | version_list "installed" \
    && nave_ls_named
}

nave_ls_remote () {
  get / | version_list "node remote"
}

nave_ls_named () {
  echo "named:"
  ls -- "$NAVE_ROOT" \
    | egrep -v '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort \
    | while read name; do
      echo "$name: $(ver $($NAVE_ROOT/$name/bin/node -v 2>/dev/null))"
    done
}

nave_ls_all () {
  nave_ls && (echo ""; nave_ls_remote)
}

ver () {
  local version="$1"
  local nonames="$2"
  version="${version#v}"
  case $version in
    lts-* | lts/*) nave_lts $version ;;
    lts | latest | stable) nave_$version ;;
    +([0-9])) nave_version_family "$version\."'[0-9]+' ;;
    +([0-9])\.) nave_version_family "$version"'[0-9]+' ;;
    +([0-9])\.+([0-9])) nave_version_family "$version" ;;
    +([0-9])\.+([0-9])\.+([0-9])) echo $version ;;
    *) [ "$nonames" = "" ] && echo $version ;;
  esac
}

nave_version_family () {
  local family="$1"
  family="${family#v}"
  get / | egrep -o $family'\.[0-9]+' | semver_sort | tail -n1
}

semver_sort () {
  sort -u -k 1,1n -k 2,2n -k 3,3n -t .
}

nave_latest () {
  get / \
    | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
    | semver_sort \
    | tail -n1
}

nave_stable () {
  nave_lts "$@"
}

nave_lts () {
  # err "nave_lts $@"
  local lts="$1"
  case $lts in
    "" | "lts/*")
      lts="$(get / | egrep -o 'latest-[^v][^/]+' | sort | uniq | tail -n1)"
      lts=${lts/latest-/}
      ;;
    lts/*)
      lts=$(basename "$lts")
      ;;
    latest-*)
      lts=${lts/latest-/}
      # err "nave_lts lts latest [$lts]"
      ;;
  esac
  # err "nave_lts lts=[$lts]"

  get latest-$lts/ | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}

version_list () {
  echo "$1:"
  egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
    | semver_sort \
    | organize_version_list
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
  [ -x "$NAVE_SRC/$version/configure" ]
}

nave_installed () {
  local version=$(ver "$1")
  [ -x "$NAVE_ROOT/$version/bin/node" ]
}

nave_use () {
  if [ -z "$1" ]; then
    err "Must supply a version"
    return 1
  fi

  local version=$(ver "$1" NONAMES)

  # if it's not a version number, then treat as a name.
  if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    nave_named "$@"
    return $?
  fi

  if [ "$version" == "$NAVENAME" ]; then
    # we're already here
    if [ $# -gt 1 ]; then
      shift
      if [ "$1" == "exec" ]; then
        shift
      fi
      exec "$@"
    else
      return 0
    fi
  fi

  nave_install "$version"
  local ret=$?
  if [ $ret -ne 0 ]; then
    err "failed to install $version"
    return $ret
  fi
  local prefix="$NAVE_ROOT/$version"
  local lvl=$[ ${NAVELVL-0} + 1 ]
  if [ $# -gt 1 ]; then
    shift
    nave_exec "$lvl" "$version" "$version" "$prefix" "$@"
  else
    nave_login "$lvl" "$version" "$version" "$prefix"
  fi
}

# internal
nave_exec () {
  nave_run "exec" "$@"
}

nave_login () {
  nave_run "login" "$@"
}

nave_run () {
  write_rcfile
  local exec="$1"
  shift
  local lvl="$1"
  shift
  local name="$1"
  shift
  local version="$1"
  shift
  local prefix="$1"
  shift
  #err "nave_run exec=$exec lvl=$lvl name=$name version=$version prefix=$prefix"

  local bin="$prefix/bin"
  local lib="$prefix/lib/node"
  local man="$prefix/share/man"
  mkdirp "$bin"
  mkdirp "$lib"
  mkdirp "$man"

  # now $@ is the command to run, or empty if it's not an exec.
  local args=()
  local isLogin

  local runShell=$SHELL
  if [ "$exec" == "exec" ]; then
    isLogin=""
    # source the nave env file, then run the command.
    args=("-c" ". $(enquote_all $NAVE_DIR/.zshenv); $(enquote_all "$@")")
  else
    case "$(basename $SHELL)" in
      zsh)
        isLogin="1"
        # no need to set rcfile, since ZDOTDIR is set.
        args=()
        ;;
      bash)
        isLogin="1"
        # bash, use --rcfile argument
        args=("--rcfile" "$NAVE_DIR/.zshenv")
        ;;
      *)
        isLogin="1"
        # use bash so we can source the rcfile we've prepared but then tell
        # bash to run the user's preferred shell
        runShell="bash"
        args=("-c" ". $NAVE_DIR/.zshenv && $SHELL")
        ;;
    esac
  fi

  local nave="$version"
  if [ "$version" != "$name" ]; then
    nave="$name"-"$version"
  fi

  # use exec to take over this shell process with whatever we're
  # executing, whether that's a login or a command.  otherwise there
  # are actually TWO subshells, rather than one.

  NAVELVL=$lvl \
  NAVEPATH="$bin" \
  NAVEVERSION="$version" \
  NAVENAME="$name" \
  NAVE="$nave" \
  npm_config_binroot="$bin"\
  npm_config_root="$lib" \
  npm_config_manroot="$man" \
  npm_config_prefix="$prefix" \
  NODE_PATH="$lib" \
  NAVE_LOGIN="$isLogin" \
  NAVE_DIR="$NAVE_DIR" \
  ZDOTDIR="$NAVE_DIR" \
    exec "$runShell" "${args[@]}"
}

nave_named () {
  local name="$1"
  shift

  local version=$(ver "$1" NONAMES)
  if [ "$version" != "" ]; then
    shift
  fi

  add_named_env "$name" "$version" || fail "failed to create $name env"

  if [ "$name" == "$NAVENAME" ] && [ "$version" == "$NAVEVERSION" ]; then
    if [ $# -gt 0 ]; then
      if [ "$1" == "exec" ]; then
        shift
      fi
      exec "$@"
    else
      return 0
    fi
  fi

  if [ "$version" = "" ]; then
    version="$(ver "$("$NAVE_ROOT/$name/bin/node" -v 2>/dev/null)")"
  fi

  local prefix="$NAVE_ROOT/$name"

  local lvl=$[ ${NAVELVL-0} + 1 ]
  # get the version
  if [ $# -gt 0 ]; then
    nave_exec "$lvl" "$name" "$version" "$prefix" "$@"
  else
    nave_login "$lvl" "$name" "$version" "$prefix"
  fi
}

add_named_env () {
  local name="$1"
  local version="$2"
  local cur="$(ver "$($NAVE_ROOT/$name/bin/node -v 2>/dev/null)" "NONAMES")"

  if [ "$name" == "" ]; then
    err "Must provide a name"
    return 1
  fi

  if [ "$version" != "" ]; then
    version="$(ver "$version" "NONAMES")"
  else
    version="$cur"
  fi

  if [ "$version" = "" ]; then
    echo "What version of node?"
    read -p "lts, lts/<name>, latest, x.y, or x.y.z > " version
    version=$(ver "$version" "NONAMES")
    if [ "$version" = "" ]; then
      err "Invalid version specifier"
      return 1
    fi
  fi

  # if that version is already there, then nothing to do.
  if [ "$cur" = "$version" ]; then
    return 0
  fi

  err "Creating new env named '$name' using node $version"

  nave_install "$version"
  local ret=$?
  if [ $ret -ne 0 ]; then
    err "failed to install $version"
    return $ret
  fi

  mkdirp "$NAVE_ROOT/$name/bin"
  mkdirp "$NAVE_ROOT/$name/lib/node"
  mkdirp "$NAVE_ROOT/$name/lib/node_modules"
  mkdirp "$NAVE_ROOT/$name/share/man"

  ln -sf -- "$NAVE_ROOT/$version/bin/node" "$NAVE_ROOT/$name/bin/node"
  ln -sf -- "$NAVE_ROOT/$version/bin/npm"  "$NAVE_ROOT/$name/bin/npm"
  ln -sf -- "$NAVE_ROOT/$version/bin/node-waf" "$NAVE_ROOT/$name/bin/node-waf"
}

nave_clean () {
  rm -rf "$NAVE_SRC/$(ver "$1")" "$NAVE_SRC/$(ver "$1")".tgz "$NAVE_SRC/$(ver "$1")"-*.tgz
}

nave_uninstall () {
  rimraf "$NAVE_ROOT/$(ver "$1")"
}

nave_help () {
  [ -z $_TESTING_NAVE_NO_HELP ] && cat <<EOF

Usage: nave <cmd>

Commands:

install <version>     Install the version specified (ex: 12.8.0)
install <name> <ver>  Install the version as a named env
use <version>         Enter a subshell where <version> is being used
use <ver> <program>   Enter a subshell, and run "<program>", then exit
use <name> <ver>      Create a named env, using the specified version.
                      If the name already exists, but the version differs,
                      then it will update the link.
usemain <version>     Install in /usr/local/bin (ie, use as your main nodejs)
clean <version>       Delete the source code for <version>
uninstall <version>   Delete the install for <version>
ls                    List versions currently installed
ls-remote             List remote node versions
ls-all                List remote and local node versions
latest                Show the most recent dist version
cache                 Clear or view the cache
help                  Output help information
auto                  Find a .naverc and then be in that env
auto <dir>            cd into <dir>, then find a .naverc, and be in that env
auto <dir> <cmd>      cd into <dir>, then find a .naverc, and run a command
                      in that env
get <variable>        Print out various nave config values.
exit                  Unset all the NAVE environs (use with 'exec')

Version Strings:
Any command that calls for a version can be provided any of the
following "version-ish" identifies:

- x.y.z       A specific SemVer tuple
- x.y         Major and minor version number
- x           Just a major version number
- lts         The most recent LTS (long-term support) node version
- lts/<name>  The latest in a named LTS set. (argon, boron, etc.)
- lts/*       Same as just "lts"
- latest      The most recent (non-LTS) version
- stable      Backwards-compatible alias for "lts".

To exit a nave subshell, type 'exit' or press ^D.
To run nave *without* a subshell, do 'exec nave use <version>'.
To clear the settings from a nave env, use 'exec nave exit'

EOF
}

if [ -z $_TESTING_NAVE_NO_MAIN ]; then
  main "$@"
else
  get_nave_dir
fi
