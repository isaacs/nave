. test/common.sh
rm () {
  return 1
}
_TESTING_NAVE_NO_MAIN=1 . nave.sh
rimraf test/cases/rimraf-fail
