. test/common.sh
unames=(
  "Darwin x86_64"
  "SunOS i486"
  "Linux i am a raspberrypie so delicious"
)
for u in "${unames[@]}"; do
  uname () {
    echo $u
  }
  _TESTING_NAVE_NO_MAIN=1 . nave.sh
  echo "$u: os=$os arch=$arch"
done
