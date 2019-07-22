. test/common.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh
touch $testdir/empty
echo 1 > $testdir/one
echo foo > $testdir/foo
get_timestamp $testdir/empty
get_timestamp $testdir/one
get_timestamp $testdir/foo
get_timestamp $testdir/missing
