#!/usr/bin/env bash
. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh

nave_use () {
  echo "mock nave use $@ (pwd=$(pwd))"
}

nave_exit () {
  echo "mock nave exit"
}

setup () {
  # a/b has a naverc
  # a/b/c/d/e has a naverc
  # a has a nvmrc
  # a/b/c has a .git, so can't walk up past it
  mkdir -p $testdir/a/b/c/d/e/f
  mkdir -p $testdir/a/b/c/.git

  # a dirs where we should not auto
  mkdir -p $testdir/no-auto/x/y/z
  mkdir -p $testdir/a/b/no-auto/{.git,x/y/z}

  echo foo 1.2.3 > $testdir/a/b/.naverc
  echo 4.2.0 > $testdir/a/b/c/d/e/.naverc
  echo bar 6.9.0 > $testdir/a/.nvmrc

  touch $testdir/a/b/c/d/e/f/file.abcdef
  touch $testdir/a/b/c/d/e/file.abcde
  touch $testdir/a/b/c/d/file.abcd
  touch $testdir/a/b/c/file.abc
  touch $testdir/a/b/file.ab
  touch $testdir/a/file.a
  touch $testdir/file
}

test_should_auto () {
  pwd
  nave_should_auto && echo 'should_auto=yes' || echo 'should_auto=no'
}

export SHELL=$(which echo)

case $1 in
  bad-dir)
    cd () {
      err mock cd fail
      return 1
    }

    exec () {
      echo "mock exec $@"
      exit
    }

    nave_auto $testdir/a/b/c
    ;;

  root) nave_auto $testdir ;;
  a) nave_auto $testdir/a ;;
  a/b) nave_auto $testdir/a/b ;;
  a/b/c) nave_auto $testdir/a/b/c ;;
  a/b/c/d/e/f) nave_auto $testdir/a/b/c/d/e/f ;;

  cmd-root) nave_auto $testdir cmd ;;
  cmd-a) nave_auto $testdir/a cmd ;;
  cmd-a/b) nave_auto $testdir/a/b cmd ;;
  cmd-a/b/c) nave_auto $testdir/a/b/c cmd ;;
  cmd-a/b/c/d/e/f) nave_auto $testdir/a/b/c/d/e/f cmd ;;

  should-not-auto)
    unset NAVE_EXIT
    setup
    cd $testdir &>/dev/null
    test_should_auto
    cd $testdir/no-auto &>/dev/null
    test_should_auto
    cd $testdir/no-auto/x &>/dev/null
    test_should_auto
    cd $testdir/no-auto/x/y &>/dev/null
    test_should_auto
    cd $testdir/no-auto/x/y/z &>/dev/null
    test_should_auto
    cd $testdir/a/b/no-auto &>/dev/null
    test_should_auto
    cd $testdir/a/b/no-auto/x &>/dev/null
    test_should_auto
    cd $testdir/a/b/no-auto/x/y &>/dev/null
    test_should_auto
    cd $testdir/a/b/no-auto/x/y/z &>/dev/null
    test_should_auto
    # .git in a/b/c prevents walkup
    cd $testdir/a/b/c &>/dev/null
    test_should_auto
    cd $testdir/a/b/c/d &>/dev/null
    test_should_auto
    # don't nave auto when already exiting a nave auto
    cd $testdir/a &>/dev/null
    NAVE_EXIT=1 test_should_auto
    # don't auto when already in the same auto
    cd $testdir/a
    NAVE_AUTO_CFG=$(cat $testdir/a/.nvmrc) \
      NAVE_AUTO_RC=$testdir/a/.nvmrc \
      test_should_auto
    ;;

  should-auto)
    unset NAVE_EXIT
    setup
    cd $testdir/a &>/dev/null
    test_should_auto
    cd $testdir/a/b &>/dev/null
    test_should_auto
    cd $testdir/a/b/c/d/e &>/dev/null
    test_should_auto
    cd $testdir/a/b/c/d/e/f &>/dev/null
    # rc if already in the same folder, but the cfg changed
    cd $testdir/a
    NAVE_AUTO_CFG='something else' \
      NAVE_AUTO_RC=$testdir/a/.nvmrc \
      test_should_auto
    ;;

  *)
    setup
    cases=(
      should-auto
      should-not-auto
      bad-dir
      a
      a/b
      a/b/c
      a/b/c/d/e/f
      cmd-a
      cmd-a/b
      cmd-a/b/c
      cmd-a/b/c/d/e/f
    )
    for i in "${cases[@]}"; do
      echo $i
      NO_CLEANUP=1 $BASH $0 $i
    done
    ;;
esac
