. test/mocks/curl.sh
testdir=test/cases/latest
mkdir -p $testdir
realmkdir=$(which mkdir)
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. nave.sh latest
rm -rf $testdir
