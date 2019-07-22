. test/common.sh
. test/mocks/curl.sh
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. nave.sh stable
. nave.sh lts
. nave.sh lts "lts/*"
. nave.sh lts "lts/argon"
. nave.sh lts latest-boron
