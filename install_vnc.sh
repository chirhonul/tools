#!/bin/bash
#
# Install tigervnc.
#
set -eu

source /etc/amnesia-env
cd ${BIN_PATH}

[ -e tigervnc-1.8.90.x86_64.tar.gz ] || {
  echo "Downloading tigervnc.."
  wget https://bintray.com/tigervnc/beta/tigervnc/1.9beta/tigervnc-1.8.90.x86_64.tar.gz
}

echo "Verifying checksum.."
echo "078c01527b93d397f6b8312117e2f6a5bbb92fc56acb775c30f64551fe9c84ec tigervnc-1.8.90.x86_64.tar.gz | sha256sum -c -"

[ -d tigervnc-1.8.90.x86_64 ] || {
  echo "Installing tigervnc.."
  tar xzfv tigervnc-1.8.90.x86_64.tar.gz
}

echo "Done."
