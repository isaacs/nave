. test/common.sh
mkdir -p $testdir/nave/src/12.6.0
cat > $testdir/nave/src/12.6.0/configure <<EOF
#!$SHELL
echo configure >&2
EOF
cat > $testdir/.naverc <<EOF
echo .naverc >&2
EOF
chmod 0755 $testdir/nave/src/12.6.0/configure
xdg
. test/mocks/curl.sh
. test/mocks/make.sh
. nave.sh test v12.6.0
cat > $testdir/nave/src/12.6.0/configure <<EOF
#!$SHELL
echo configure fail >&2
exit 1
EOF
. nave.sh test v12.6.0
