. test/common.sh
realmkdir=$(which mkdir)
unset XDG_CONFIG_HOME
export HOME=
export PREFIX=$(cd -- $testdir &>/dev/null ; pwd)
mkdir () {
  echo "mkdir $@"
  $realmkdir "$@"
}
_TESTING_NAVE_NO_HELP=1 . nave.sh
