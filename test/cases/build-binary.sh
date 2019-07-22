. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

get_nave_dir

os= build_binary 12.6.0 $testdir/no-os
echo "no os $?"

. test/mocks/tar-noop.sh
build_binary 12.6.0 $testdir/success
echo "successwin $?"

get () {
  return 1
}
. test/mocks/tar-fail.sh
build_binary 12.6.0 $testdir/failure
echo "get fail $?"
