. test/common.sh
realmkdir=$(which mkdir)
XDG_CONFIG_HOME=
HOME=$(cd -- $testdir &>/dev/null ; pwd)
mkdir () {
  echo "mkdir $@"
  $realmkdir "$@"
}
_TESTING_NAVE_NO_HELP=1 . nave.sh
