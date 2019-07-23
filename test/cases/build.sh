. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

get_nave_dir

# infer jobs from sysctl -n hw.ncpu
JOBS=
sysctl () {
  echo 8
}

mkdir -p $testdir/success
build 12.6.0 $testdir/success
echo "successwin $?" >&2

build_binary () {
  echo "test build binary failure" >&2
  return 1
}

build 12.6.0 $testdir/bin-build-fail
echo "bin build fail $?" >&2

make () {
  if [ "$1" == "install" ]; then
    echo "mock make install failure" >&2
    return 1
  else
    $(which make) "$@"
  fi
}

build 12.6.0 $testdir/make-install-fail
echo "make install fail $?" >&2

make () {
  echo "make fail" >&2
  return 1
}

build 12.6.0 $testdir/make-fail
echo "make fail $?" >&2

cat >$testdir/nave/src/12.6.0/configure <<EOF
#!/usr/bin/env bash
echo "mock failure to configure" >&2
exit 1
EOF

build 12.6.0 $testdir/configure-fail
echo "configure fail $?" >&2

nave_fetch () {
  echo "nave_fetch mock fail" >&2
  return 1
}
build 12.6.0 $testdir/fetch-fail
echo "fetch fail $?" >&2
