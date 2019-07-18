. test/mock-curl.sh
testdir=test/cases/ls-remote/
mkdir -p $testdir
realmkdir=$(which mkdir)
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. nave.sh ls-remote
rm -rf $testdir
