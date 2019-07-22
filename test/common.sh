testcase=$0
testname=$(basename "$testcase" .sh)
testdir=test/cases/$testname
mkdir -p "$testdir"
__nave_test_cleanup () {
  rm -rf "$testdir"
}
trap __nave_test_cleanup EXIT

xdg () {
  export XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
}

if [ "$SNAPSHOT" != "1" ]; then
  curl () {
    if [ "$1" != "--version" ]; then
      echo "curl not allowed" >&2
      exit 99
    fi
  }
fi
