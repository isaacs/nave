#!/usr/bin/env bash
git config --global user.email "$1"
shift
git config --global user.name "$1"
shift
message="$1"
shift
if [ $(git status --porcelain "$@" | egrep '^ M' | wc -l) -gt 0 ]; then
  for f in "$@"; do
    if [ -f $f ]; then
      git add "$f"
    fi
  done
  git commit -m "$message"
  git push || git pull --rebase
  git push
fi
