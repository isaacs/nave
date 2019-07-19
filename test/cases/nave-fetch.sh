testdir=test/cases/nave-fetch/
mkdir -p $testdir
XDG_CONFIG_HOME=$(cd -- $testdir &>/dev/null ; pwd)
. test/mocks/curl.sh
. test/mocks/tar-noop.sh
. nave.sh fetch v12.6.0

# fetch again just to hit the "already has" code path
. nave.sh fetch v12.6.0

# hit the case where the html download fails, so we use
# the cache, even though it's expired
rm $testdir/nave/cache/v12.6.0/SHASUMS256.txt-timestamp
. test/mocks/curl-fail.sh
. nave.sh fetch v12.6.0
if [ -f $testdir/nave/cache/v12.6.0/SHASUMS256.txt-timestamp ]; then
  echo 'ERROR: timestamp should not be there!' >&2
  exit 99
fi
if [ -f $testdir/nave/cache/v12.6.0/SHASUMS256.txt.tmp ]; then
  echo 'ERROR: temp file should not be there!' >&2
  exit 99
fi

# now fail to unpack it
. test/mocks/curl.sh
. test/mocks/tar-fail.sh
. nave.sh fetch v12.5.0
rm -rf $testdir
