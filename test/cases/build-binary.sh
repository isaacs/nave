. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

. test/mocks/tar-noop.sh
build_binary 12.6.0 $testdir/success
echo "successwin $?"

uname () {
  echo 'nope'
}
# un-memoize osarch
_TESTING_NAVE_NO_MAIN=1 . nave.sh
build_binary 12.6.0 $testdir/no-os
echo "no os $?"

. test/mocks/uname.sh
# un-memoize osarch
_TESTING_NAVE_NO_MAIN=1 . nave.sh
get () {
  return 1
}
. test/mocks/tar-fail.sh
build_binary 12.6.0 $testdir/failure
echo "get fail $?"
