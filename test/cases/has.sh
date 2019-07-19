. test/mocks/curl.sh
testdir=test/cases/has
mkdir -p $testdir
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. nave.sh has 1.2.3 && echo 'has it' || echo 'no has'
mkdir -p $testdir/nave/src/1.2.3
touch $testdir/nave/src/1.2.3/configure
chmod 0755 $testdir/nave/src/1.2.3/configure
. nave.sh has 1.2.3 && echo 'has it' || echo 'no has'
rm -rf $testdir
