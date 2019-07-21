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
    cmp tmp/$testname $snapfile
    local cmpres=$?
    if [ $cmpres -ne 0 ]; then
      echo "not ok $n - $testname"
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
  local s
  if ! [ -f $snapfile ]; then
    s=1
  else
    s=$SNAPSHOT
  fi

  # prefix stderr with err> and stdout with out>
  # then filter out some machine-specific things
  if [ -n "$COV" ]; then
    SNAPSHOT=$s kcov --include-path=nave.sh coverage "$testcase" >tmp/$testname.stdout 2>tmp/$testname.stderr
  else
    SNAPSHOT=$s bash "$testcase" >tmp/$testname.stdout 2>tmp/$testname.stderr
  fi
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
  if [ $fails -eq 0 ]; then
    echo '# all tests passing'
    rm -rf tmp
  else
    echo "# failed $fails of $n tests"
  fi
  if [ -n "$COV" ]; then
    kcov --merge coverage coverage
  fi
}

main "$@"
