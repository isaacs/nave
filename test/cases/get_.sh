. test/common.sh
curl () {
  echo "curl $@"
}

_TESTING_NAVE_NO_MAIN=1 . nave.sh
get_ asdf
