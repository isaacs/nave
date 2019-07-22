. test/common.sh
. test/mocks/curl.sh
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. nave.sh ls-remote
