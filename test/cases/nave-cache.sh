. test/common.sh
export NAVE_DIR=$testdir
_TESTING_NAVE_NO_MAIN=1 . nave.sh
nave_cache asdf
touch $testdir/cache/foo
mkdir -p $testdir/cache/a/{b,c}/d
# filter out the '<n> directories, 1 file' bit, since
# that may or may not include root dir argument.
nave_cache tree | grep -v 'directories, 1 file'
nave_cache ls | sort
nave_cache clear
nave_cache ls
