#!/usr/bin/env bash

fails=0

runTest () {
  local testcase=$1
  local n=$2
  local testname=$(basename "$testcase" .sh)

  # prefix stderr with err> and stdout with out>
  # then filter out some machine-specific things
  #local output=$(( bash $testcase 2> >(sed -e 's/^/err> /')) 2>&1)
  if [ -n "$COV" ]; then
    kcov --include-path=nave.sh coverage "$testcase" >tmp/$testname.raw 2>&1
  else
    bash "$testcase" >tmp/$testname.raw 2>&1
  fi
  local code=$?
  echo $'\n---\ncode='$code >> tmp/$testname.raw
  # filter out some machine-specific things
  cat tmp/$testname.raw | sed -e "s#$PWD#\$PWD#g" > tmp/$testname
  mkdir -p snapshots
  local snapfile=snapshots/$testname
  if [ -n "${SNAPSHOT}" ] || ! [ -f "$snapfile" ]; then
    cp tmp/$testname $snapfile
    echo "ok $n - $testname {"
    echo "    1..1"
    echo "    ok - wrote snapshot"
    echo "}"
  else
    cmp --silent tmp/$testname $snapfile
    local cmpres=$?
    if [ $cmpres -ne 0 ]; then
      echo "not ok $n - $testname {"
      echo "    1..1"
      echo "    not ok - should match snapshot"
      echo "}"
      let 'fails++'
    else
      #echo "ok $n - $testname"
      echo "ok $n - $testname {"
      echo "    1..1"
      echo "    ok - matches snapshot"
      echo "}"
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
  else
    echo "# failed $fails of $n tests"
  fi
}

main "$@"
