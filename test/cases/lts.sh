. test/common.sh
. test/mocks/curl.sh
. nave.sh stable
. nave.sh lts
. nave.sh lts "lts/*"
. nave.sh lts "lts/argon"
. nave.sh lts latest-boron
