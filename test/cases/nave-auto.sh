#!/usr/bin/env bash
. test/common.sh
. test/mocks/uname.sh
. test/mocks/curl.sh
. test/mocks/tar-unpack.sh
xdg
_TESTING_NAVE_NO_MAIN=1 . nave.sh

nave_use () {
  echo "mock nave use $@ (pwd=$(pwd))"
}

nave_exit () {
  echo "mock nave exit"
}

#exec () {
#  echo "mock exec $@"
#  exit
#}

setup () {
  mkdir -p $testdir/a/b/c/d/e/f
  mkdir -p $testdir/a/b/c/.git
  echo foo 1.2.3 > $testdir/a/b/.naverc
  echo 4.2.0 > $testdir/a/b/c/d/e/.naverc
  echo bar 6.9.0 > $testdir/.naverc
  touch $testdir/a/b/c/d/e/f/file.abcdef
  touch $testdir/a/b/c/d/e/file.abcde
  touch $testdir/a/b/c/d/file.abcd
  touch $testdir/a/b/c/file.abc
  touch $testdir/a/b/file.ab
  touch $testdir/a/file.a
  touch $testdir/file
}

export SHELL=$(which echo)

case $1 in
  bad-dir)
    cd () {
      err mock cd fail
      return 1
    }
    nave_auto $testdir/a/b/c
    ;;

  a) nave_auto $testdir/a ;;
  a/b) nave_auto $testdir/a/b ;;
  a/b/c) nave_auto $testdir/a/b/c ;;
  a/b/c/d/e/f) nave_auto $testdir/a/b/c/d/e/f ;;

  cmd-a) nave_auto $testdir/a cmd ;;
  cmd-a/b) nave_auto $testdir/a/b cmd ;;
  cmd-a/b/c) nave_auto $testdir/a/b/c cmd ;;
  cmd-a/b/c/d/e/f) nave_auto $testdir/a/b/c/d/e/f cmd ;;

  *)
    setup
    cases=(
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
