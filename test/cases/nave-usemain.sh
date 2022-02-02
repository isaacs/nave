. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh

# pretend we have an old version already
mkdir $testdir/bin
cat > $testdir/bin/node <<EOF
#!/usr/bin/env bash
echo v1.2.3
EOF
chmod 0755 $testdir/bin/node
export PATH=$testdir/bin:$PATH

export PREFIX=$testdir

NAVELVL=1 nave_usemain
nave_usemain 12.6.0
which node
node -v
find $testdir | sort

rm -rf $testdir
mkdir $testdir

mkdir $testdir/bin
cat > $testdir/bin/node <<EOF
#!/usr/bin/env bash
echo i am a real worm i am an actual worm
EOF
chmod 0755 $testdir/bin/node
export PATH=$testdir/bin:$PATH

nave_usemain 12.6.0
which node
node -v
find $testdir | sort

# using the same one over again
nave_usemain 12.6.0
