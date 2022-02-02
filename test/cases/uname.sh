. test/common.sh
unames=(
  "Darwin x86_64"
  "SunOS i486"
  "Linux i am a raspberrypie so delicious"
  "Darwin moxy.lan 21.2.0 Darwin Kernel Version 21.2.0: Sun Nov 28 20:28:41 PST 2021; root:xnu-8019.61.5~1/RELEASE_ARM64_T6000 arm64"
  "Linux aarch64"
)
for u in "${unames[@]}"; do
  uname () {
    echo $u
  }
  _TESTING_NAVE_NO_MAIN=1 . nave.sh
  echo "$u: $(osarch)"
done
