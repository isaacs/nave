. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

exec () {
  echo "mock exec $@"
  env | grep NAVE | sort
  echo ""
}

SHELL=/bin/bash nave_run exec  1 1.2.3  1.2.3 $testdir/nave/installed/1.2.3
SHELL=/bin/bash nave_run login 2 1.2.3  1.2.3 $testdir/nave/installed/1.2.3
SHELL=/bin/bash nave_run exec  3 myname 1.2.3 $testdir/nave/installed/myname
SHELL=/bin/bash nave_run login 4 myname 1.2.3 $testdir/nave/installed/myname
SHELL=/bin/zsh  nave_run exec  5 1.2.3  1.2.3 $testdir/nave/installed/1.2.3
SHELL=/bin/zsh  nave_run login 6 1.2.3  1.2.3 $testdir/nave/installed/1.2.3
SHELL=/bin/fish nave_run exec  7 1.2.3  1.2.3 $testdir/nave/installed/1.2.3
SHELL=/bin/fish nave_run login 8 1.2.3  1.2.3 $testdir/nave/installed/1.2.3
