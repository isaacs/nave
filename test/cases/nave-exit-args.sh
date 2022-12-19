. test/common.sh
SHELL=$(which echo)
export NAVE_DIR=/tmp
export PATH=/testing/nave/path:$PATH
export NAVEPATH=/testing/nave/path
echo NAVE_EXIT=${NAVE_EXIT}
. nave.sh exit some args
echo NAVE_EXIT=${NAVE_EXIT}
