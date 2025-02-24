. test/common.sh
mkdir -p $testdir/nave
touch $testdir/nave/.zshenv
chmod 0444 $testdir/nave/.zshenv
ls -l $testdir/nave/.zshenv | awk '{print $1}' | grep -E -o '[rwx]'
_TESTING_NAVE_NO_HELP=1 _TESTING_NAVE_NO_EXIT=1 . nave.sh
cat $testdir/nave/.zshenv
chmod 0644 $testdir/nave/.zshenv
