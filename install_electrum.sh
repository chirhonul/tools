#!/bin/sh
#
# Install dependencies to use Ledger Nano S.
#
cd /mnt/bin

[ -e Electrum-3.1.3.tar.gz ] || {
  echo "Downloading electrum.."
  torify pip3 install https://download.electrum.org/3.1.3/Electrum-3.1.3.tar.gz 
  echo "3e5aedb52184f2237eb81194539f27b148045e266e46aca0e42ae53f9a47a216  Electrum-3.1.3.tar.gz" | sha256sum -c
}
