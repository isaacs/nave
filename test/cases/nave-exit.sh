SHELL=$(which env)
export NAVE_DIR=/tmp
export PATH=/testing/nave/path:$PATH
export NAVEPATH=/testing/nave/path
. nave.sh exit | grep NAVE
