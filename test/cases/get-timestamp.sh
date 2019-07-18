_TESTING_NAVE_NO_MAIN=1 . nave.sh
testdir=test/cases/get-timestamp
mkdir -p $testdir
touch $testdir/empty
echo 1 > $testdir/one
echo foo > $testdir/foo
get_timestamp $testdir/empty
get_timestamp $testdir/one
get_timestamp $testdir/foo
get_timestamp $testdir/missing
rm -rf $testdir
