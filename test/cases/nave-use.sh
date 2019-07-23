. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

nave_named () {
  echo "mock nave_named $@"
}

case $1 in
  enter-login)
    nave_use 12.6.0 <<END
    env | grep NAVE | sort
END
    ;;

  named)
    nave_use foo 12.6.0
    ;;

  install-fail)
    nave_install () {
      return 1
    }
    nave_use 12.6.0
    ;;

  enter-exec)
    nave_use 12.6.0 bash -c 'env | grep NAVE | sort'
    ;;

  here-exec)
    NAVENAME=12.6.0 NAVEVERSION=12.6.0 nave_use 12.6.0 \
      bash -c 'env | grep NAVE | sort'
    ;;

  here-noop)
    NAVENAME=12.6.0 NAVEVERSION=12.6.0 nave_use 12.6.0
    ;;

  noversion)
    nave_use ""
    ;;

  *)
    cases=(
      enter-login
      named
      install-fail
      enter-exec
      here-exec
      here-noop
      noversion
    )
    for i in "${cases[@]}"; do
      echo $i
      NO_CLEANUP=1 $BASH $0 $i
      echo "exit=$?"
    done
    ;;
esac
