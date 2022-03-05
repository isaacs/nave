. test/common.sh
. test/mocks/uname-arm64.sh
. test/mocks/arch.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh

_TESTING_NAVE_NO_MAIN=1 . nave.sh
nave_install 4
