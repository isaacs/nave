. test/mocks/curl.sh
testdir=test/cases/lts
mkdir -p $testdir
realmkdir=$(which mkdir)
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. nave.sh stable
. nave.sh lts
. nave.sh lts "lts/*"
. nave.sh lts "lts/argon"
. nave.sh lts latest-boron
rm -rf $testdir
