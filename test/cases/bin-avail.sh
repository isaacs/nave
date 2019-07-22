. test/common.sh
. test/mocks/uname.sh
_TESTING_NAVE_NO_MAIN=1 . nave.sh

vers=(12.6.0 0.8.5 0.7.9)
for v in "${vers[@]}"; do
  echo -n "$v "
  if ! bin_available "$v"; then
    echo "no"
  else
    echo "yes"
  fi
done

echo -n "no os, 12.6.0 "
if ! os= bin_available "$v"; then
  echo "no"
else
  echo "yes"
fi

echo -n "NAVE_SRC_ONLY=1 12.6.0 "
if ! NAVE_SRC_ONLY=1 bin_available "$v"; then
  echo "no"
else
  echo "yes"
fi
