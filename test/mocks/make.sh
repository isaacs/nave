#!/usr/bin/env bash
# might add more to this later, but for now just log the things
make () {
  echo "MOCK MAKE $@" >&2
  echo " cwd: $(pwd)" >&2
}
