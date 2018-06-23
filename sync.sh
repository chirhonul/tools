#!/bin/bash
cd ~/src/github.com/chirhonul/bisq
while true; do
  rsync -az --exclude '.git' . s0:src/github.com/chirhonul/bisq/
  sleep 5
done

