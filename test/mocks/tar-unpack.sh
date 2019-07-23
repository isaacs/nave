#!/usr/bin/env bash
# just a no-op so tests don't take a long time if they don't
# care about the actual unpacked results.
MOCK_UNPACK_TARBALL=test/mocks/mock-node-tarball.tgz
MOCK_FAIL_TARBALL=test/mocks/mock-node-tarball-fail-configure.tgz
tar () {
  echo "unpacking mock: tar $@" >&2
  local cmd=$1
  local filemaybe=$2
  shift
  if [[ $cmd =~ .*f ]]; then
    shift
  fi
  $(which tar) xvf $MOCK_UNPACK_TARBALL "$@"
}
