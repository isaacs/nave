#!/usr/bin/env bash

fails=0

runTest () {
  local testcase=$1
  local n=$2
  local testname=$(basename "$testcase" .sh)

  # prefix stderr with err> and stdout with out>
  # then filter out some machine-specific things
  if [ -n "$COV" ]; then
    kcov --include-path=nave.sh coverage "$testcase" >tmp/$testname.raw 2>&1
  else
    bash "$testcase" >tmp/$testname.raw 2>&1
  fi
  local code=$?
  if [ $code -eq 99 ]; then
    echo "Bailout! $testcase failed in a bad way"
    echo >&2
    cat tmp/$testname.raw | sed -e 's|^|# |g' >&2
    echo >&2
  fi
  echo $'\n---\ncode='$code >> tmp/$testname.raw
  # filter out some machine-specific things
  cat tmp/$testname.raw | \
    sed -e "s#$PWD#\$PWD#g" | \
    sed -Ee "s|nave.sh: line [0-9]+|nave.sh: line #|g" > tmp/$testname
  mkdir -p snapshots
  local snapfile=snapshots/$testname
  if [ -n "${SNAPSHOT}" ] || ! [ -f "$snapfile" ]; then
    cp tmp/$testname $snapfile
    echo "ok $n - $testname"
  else
    cmp tmp/$testname $snapfile
    local cmpres=$?
    if [ $cmpres -ne 0 ]; then
      echo "not ok $n - $testname"
      let 'fails++'
    else
      echo "ok $n - $testname"
    fi
  fi
}

main () {
  rm -rf tmp
  mkdir -p tmp
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
