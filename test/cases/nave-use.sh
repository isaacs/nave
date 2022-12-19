. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
. test/mocks/arch.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh

setup () {
  mkdir -p $testdir/has/nm/node_modules/.bin
  mkdir -p $testdir/has/nm/sub/dir
  mkdir -p $testdir/has/pj
  mkdir -p $testdir/has/pj/sub/dir
  touch $testdir/has/pj/package.json
}

nave_named () {
  echo "mock nave_named $@"
}

case $1 in
  enter-login)
    nave_use 12.6.0 <<END
    env | grep NAVE | sort
END
    ;;

  npx-nm)
    setup
    cd $testdir/has/nm &>/dev/null
    NAVE_NPX=1 nave_use 12.6.0 bash -c 'env | grep NAVE | sort; pwd'
    ;;

  npx-pj)
    setup
    cd $testdir/has/pj &>/dev/null
    NAVE_NPX=1 nave_use 12.6.0 bash -c 'env | grep NAVE | sort; pwd'
    ;;

  npx-nm-sub)
    setup
    cd $testdir/has/nm/sub/dir &>/dev/null
    NAVE_NPX=1 nave_use 12.6.0 bash -c 'env | grep NAVE | sort; pwd'
    ;;

  npx-pj-sub)
    setup
    cd $testdir/has/pj/sub/dir &>/dev/null
    NAVE_NPX=1 nave_use 12.6.0 bash -c 'env | grep NAVE | sort; pwd'
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
      exec bash -c 'env | grep NAVE | sort'
    ;;

  here-noop)
    NAVENAME=12.6.0 NAVEVERSION=12.6.0 nave_use 12.6.0
    ;;

  noversion)
    nave_use ""
    ;;

  *)
    setup
    cases=(
      enter-login
      named
      npx-nm
      npx-pj
      npx-nm-sub
      npx-pj-sub
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
