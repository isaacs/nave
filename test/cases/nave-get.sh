. test/common.sh
xdg
curl () {
  echo "hello this is curl"
}

_TESTING_NAVE_NO_MAIN=1 . nave.sh
nave_get root
nave_get cache
nave_get dir
nave_get src
nave_get cache-dur
nave_get ua
nave_get src-only
nave_get
nave_get asdf
