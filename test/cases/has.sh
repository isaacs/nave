. test/common.sh
. test/mocks/curl.sh
. nave.sh has 1.2.3 && echo 'has it' || echo 'no has'
mkdir -p $testdir/nave/src/1.2.3
touch $testdir/nave/src/1.2.3/configure
chmod 0755 $testdir/nave/src/1.2.3/configure
. nave.sh has 1.2.3 && echo 'has it' || echo 'no has'
