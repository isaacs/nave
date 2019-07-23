. test/common.sh
xdg
rm () {
  echo "mock rm $@" >&2
}
. nave.sh clean 1.2.3
rm () {
  $(which rm)  "$@"
}
