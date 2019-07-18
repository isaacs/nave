testdir=test/cases/rcfile-silent-fail
mkdir -p $testdir/nave
touch $testdir/nave/.zshenv
chmod 0444 $testdir/nave/.zshenv
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
_TESTING_NAVE_NO_HELP=1 _TESTING_NAVE_NO_EXIT=1 . nave.sh
echo 'cleanup'
chmod 0644 $testdir/nave/.zshenv
rm -rf $testdir
