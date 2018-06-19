#!/bin/bash
#
# Check status of git repos.
#
set -euo pipefail

for d in ~/src/github.com/chirhonul/*; do
  echo "Checking ${d}.."
  cd ${d}
  git status ${d}
  echo "----------------------------------------------------------------"
done

for f in ~/docs/*; do
  echo "UNLOCKED DOC:"
  echo "${f}"
  echo
done
