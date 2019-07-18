#!/usr/bin/env bash
_curl=$(which curl)
fixtures=test/fixtures
curl () {
  if [ "$1" = "--version" ]; then
    echo "i am just a mock curl"
    return 0
  fi

  # we always have to call curl with the url as the first argument
  local url=$1
  local dist=${NODEDIST:-https://nodejs.org/dist}
  path=${url#$dist}
  if [ $path = $url ]; then
    echo "ERROR: requesting unexpected url not on dist host" >&2
    echo "  url: $url" >&2
    echo " dist: $dist" >&2
    return 1
  fi

  path=${path##/}
  path=${path%%/}
  if [ "$path" != "" ]; then
    path=/${path}
  fi
  f=$fixtures$path/_result
  f=${f//\/+/\/}
  if [ -f $f ]; then
    cat $f
    return 0
  fi

  if [ -z "$SNAPSHOT" ]; then
    echo "only do actual fetches in snapshot mode" >&2
    return 1
  fi

  # ok, do an actual curl to add the fixture
  mkdir -p -- $(dirname $f)
  $_curl -s "$@" | tee "$f"
}
