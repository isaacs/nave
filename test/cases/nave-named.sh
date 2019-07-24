. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

case $1 in
  enter-login)
    nave_named success 12.6.0 <<END
    env | grep NAVE | sort
END
    ;;

  enter-exec)
    nave_named success bash -c 'env | grep NAVE | sort'
    ;;

  here-exec)
    NAVENAME=success NAVEVERSION=12.6.0 nave_named success 12.6.0 \
      exec bash -c 'env | grep NAVE | sort'
    ;;

  here-noop)
    NAVENAME=success NAVEVERSION=12.6.0 nave_named success 12.6.0
    ;;

  *)
    cases=(enter-login enter-exec here-noop here-exec)
    for i in "${cases[@]}"; do
      echo $i
      NO_CLEANUP=1 $BASH $0 $i
      echo "exit=$?"
    done
    ;;
esac
