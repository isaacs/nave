. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-noop.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh
get_nave_dir
nave_install deadbeef
mkdir -p $testdir/nave/installed/1.2.3/bin
touch $testdir/nave/installed/1.2.3/bin/node
chmod 0755 $testdir/nave/installed/1.2.3/bin/node
nave_install 1.2.3
echo "install exit $?" >&2

build () {
  echo "mock build pass $@" >&2
}
nave_install 12.6.0
echo "install exit $?" >&2

build () {
  echo "mock build fail $@" >&2
  return 1
}
nave_install 12.6.0
echo "install exit $?" >&2
