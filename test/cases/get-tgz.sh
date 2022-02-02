. test/common.sh
. test/mocks/curl.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh

# test that an invalid cache will be blown away and we'll still
# get the correct shasum
mkdir -p $testdir/nave/cache/v12.6.0
touch $testdir/nave/cache/v12.6.0/SHASUMS256.txt

# this echos the filename in the cache
get_tgz v12.6.0/node-v12.6.0-darwin-x64.tar.gz

# test that a shasum mismatch will not be a silent success
mv $testdir/nave/cache/v12.6.0/SHASUMS256.txt{,.bak}
cat > $testdir/nave/cache/v12.6.0/SHASUMS256.txt <<EOF
___intentionally-invalid-shasum___  node-v12.6.0-darwin-x64.tar.gz
EOF
get_tgz v12.6.0/node-v12.6.0-darwin-x64.tar.gz
mv $testdir/nave/cache/v12.6.0/SHASUMS256.txt{.bak,}

# don't download if we don't have a shasum
get_tgz v12.6.0/not-a-thing.tar.gz

# fail if not cached and curl fails
curl () {
  return 1
}
rm test/cases/get-tgz/nave/cache/v12.6.0/*.tgz
get_tgz v12.6.0/node-v12.6.0-darwin-x64.tar.gz
echo $?

find $testdir/nave | sort
