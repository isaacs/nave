. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh

# an old version already in the prefix, plus a header it installed
# that the new version does not ship
mkdir -p $testdir/bin $testdir/include/x
cat > $testdir/bin/node <<EOF
#!/usr/bin/env bash
echo v1.2.3
EOF
chmod 0755 $testdir/bin/node
touch $testdir/include/x/old-header.h
export PATH=$testdir/bin:$PATH
export PREFIX=$testdir

# leftovers from a previous usemain in the staging dir
mkdir -p $testdir/nave/main/lib
touch $testdir/nave/main/lib/stale

inode () {
  ls -i "$1" | awk '{print $1}'
}
before=$(inode $testdir/bin/node)

nave_usemain 12.6.0
node -v

if [ "$(inode $testdir/bin/node)" != "$before" ]; then
  echo "bin/node replaced with a new file"
else
  echo "bin/node overwritten in place"
fi
find $testdir -not -path "$testdir/nave/cache*" | sort
