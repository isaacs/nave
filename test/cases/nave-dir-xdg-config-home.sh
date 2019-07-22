. test/common.sh
realmkdir=$(which mkdir)
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
HOME=
mkdir () {
  echo "mkdir $@"
  $realmkdir "$@"
}
_TESTING_NAVE_NO_HELP=1 . nave.sh
