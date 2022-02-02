#!/usr/bin/env bash
# just a no-op so tests don't take a long time if they don't
# care about the actual unpacked results.
tar () {
  echo "unpacking mock: tar $@" >&2
  local cmd=$1
  local filemaybe=$2
  shift
  if [[ $cmd =~ .*f ]]; then
    shift
  fi
  $(which tar) xvf test/mocks/mock-node-tarball.tgz "$@"
  cat >/dev/null
}
