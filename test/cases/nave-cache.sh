testdir=test/cases/nave-cache
mkdir -p $testdir
NAVE_DIR=$testdir
_TESTING_NAVE_NO_MAIN=1 . nave.sh
nave_cache asdf
touch $testdir/cache/foo
mkdir -p $testdir/cache/a/{b,c}/d
nave_cache tree
nave_cache ls
nave_cache clear
nave_cache ls
rm -rf $testdir
