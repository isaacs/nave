. test/common.sh
curl () {
  echo "hello this is curl"
}
_TESTING_NAVE_NO_MAIN=1 . nave.sh
echo $NAVEUA
