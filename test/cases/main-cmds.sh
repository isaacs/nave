. test/common.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh
nave_ls_remote () {
  echo "nave_ls_remote $@"
}
nave_ls_all () {
  echo "nave_ls_remote $@"
}

nave_auto () {
  echo "nave_auto $@"
}
nave_cache () {
  echo "nave_cache $@"
}
nave_exit () {
  echo "nave_exit $@"
}
nave_install () {
  echo "nave_install $@"
}
nave_fetch () {
  echo "nave_fetch $@"
}
nave_use () {
  echo "nave_use $@"
}
nave_clean () {
  echo "nave_clean $@"
}
nave_test () {
  echo "nave_test $@"
}
nave_named () {
  echo "nave_named $@"
}
nave_ls () {
  echo "nave_ls $@"
}
nave_uninstall () {
  echo "nave_uninstall $@"
}
nave_usemain () {
  echo "nave_usemain $@"
}
nave_latest () {
  echo "nave_latest $@"
}
nave_stable () {
  echo "nave_stable $@"
}
nave_has () {
  echo "nave_has $@"
}
nave_installed () {
  echo "nave_installed $@"
}
nave_help () {
  echo "nave_help $@"
}

cmds=(
ls-remote
ls-all
auto
cache
exit
install
fetch
use
clean
test
named
ls
uninstall
usemain
latest
stable
has
installed
flerb
)

for c in "${cmds[@]}"; do
  main $c 1 2 3
done
