#!/bin/bash
#
# Check status of git repos.
#
set -euo pipefail
for d in ~/src/github.com/chirhonul/*; do
  [ -d ${d}/.git ] || continue
  echo "Checking ${d}.."
  cd ${d}
  git status ${d}
  echo "----------------------------------------------------------------"
done

[ -e ~/docs ] && {
  echo "UNLOCKED DOC:"
  cd ~/docs/
  for f in *; do
    echo "${f}"
  done
}
