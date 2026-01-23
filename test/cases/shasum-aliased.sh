alias shasum="ls -laF"
. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh
get_nave_dir
