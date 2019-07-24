#!/usr/bin/env bash

fails=0

# filter out machine-specific things
filterTest () {
  sed -e "s#$PWD#\$PWD#g" | sed -Ee "s|nave.sh: line [0-9]+|nave.sh: line #|g"
}

afterTest () {
  local n=$1
  local testname=$2
  local code=$3
  filterTest >tmp/$testname <<EOF
STDOUT
$(cat tmp/$testname.stdout)
STDERR
$(cat tmp/$testname.stderr)
CODE ${code}
EOF
  rm tmp/$testname.stderr tmp/$testname.stdout
  if [ $code -eq 99 ]; then
    echo "Bailout! $testcase failed in a bad way"
    echo >&2
    cat tmp/$testname | sed -e 's|^|# |g' >&2
    echo >&2
  fi

  local snapfile=snapshots/$testname
  if [ -n "${SNAPSHOT}" ] || ! [ -f "$snapfile" ]; then
    cp tmp/$testname $snapfile
    echo "ok $n - $testname"
  else
    cmp tmp/$testname $snapfile &>/dev/null
    local cmpres=$?
    if [ $cmpres -ne 0 ]; then
      echo "not ok $n - $testname"
      git diff --no-index --color $snapfile tmp/$testname | \
        sed -Ee 's|^|# |g'
      echo ""
      return 1
    else
      echo "ok $n - $testname"
      return 0
    fi
  fi
}

runTest () {
  local testcase=$1
  local n=$2
  local testname=$(basename "$testcase" .sh)
  local snapfile=snapshots/$testname
  if ! [ -f $snapfile ]; then
    SNAPSHOT=1
  fi

  local cmd
  if [ -n "$COV" ]; then
    cmd=(kcov --include-path=nave.sh coverage "$testcase")
  else
    cmd=(bash "$testcase")
  fi
  local out="tmp/$testname.stdout"
  local err="tmp/$testname.stderr"

  SNAPSHOT=$SNAPSHOT "${cmd[@]}" >"$out" 2>"$err"
  afterTest $n $testname $?
}

main () {
  rm -rf tmp
  mkdir -p tmp
  mkdir -p snapshots
  local n=0
  local tests=(test/cases/*.sh)
  echo "TAP version 13"
  echo "1..${#tests[@]}"
  local pids=()
  for i in "${tests[@]}"; do
    let 'n++' || true
    runTest "$i" "$n" &
    pids+=($!)
  done
  for p in "${pids[@]}"; do
    wait "$p"
    if ! [ $? -eq 0 ]; then
      let 'fails++'
    fi
  done
  if [ -n "$COV" ]; then
    kcov --merge coverage coverage
  fi
  if [ $fails -eq 0 ]; then
    echo -e '\u001b[37m\u001b[42m# all tests passing\u001b[49m\u001b[39m'
    rm -rf tmp
  else
    echo -e "\u001b[31m\u001b[40m# failed $fails of $n tests\u001b[49m\u001b[39m"
    echo ""
    return 1
  fi
}

main "$@"
