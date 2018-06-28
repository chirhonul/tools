#!/bin/bash
cd ~/src/github.com/chirhonul/bisq
while true; do
  rsync -vaz --exclude '.git' . s0:src/github.com/chirhonul/bisq/
  sleep 5
done
# rsync -vaz --delete s2:src/github.com/chirhonul/bisq/ .
