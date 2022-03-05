. test/common.sh
. test/mocks/uname-arm64.sh
. test/mocks/no-arch.sh
. test/mocks/curl.sh

_TESTING_NAVE_NO_MAIN=1 . nave.sh
build () {
  echo "BUILD $1"
}
nave_install 4
