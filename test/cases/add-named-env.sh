. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh
get_nave_dir
add_named_env success 12.6.0
readlink $testdir/nave/installed/success/bin/node

# install the same one again, still points at the same dir
# exercises the "no need to install" code path
add_named_env success 12.6.0
readlink $testdir/nave/installed/success/bin/node

# ensure the named env is there, take whatever version it has
add_named_env success
readlink $testdir/nave/installed/success/bin/node

# change to a new version
add_named_env success 12.5.0
readlink $testdir/nave/installed/success/bin/node

# specify the version via cli
echo 12.6.0 | add_named_env foo
readlink $testdir/nave/installed/foo/bin/node

echo not a valid version | add_named_env invalid
echo "exit=$?"
