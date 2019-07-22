. test/common.sh
NAVE_DIR=/please/no/make/me
mkdir () {
  echo "mock mkdir $@" >&2
  return 1
}
. nave.sh
