#!/bin/sh
#
# Install Bitcoin Core.
#
set -eu

cd ~/bin
[ -e bitcoin-0.17.0-x86_64-linux-gnu.tar.gz ] || {
  echo "Downloading bitcoin.."
  torify wget https://bitcoincore.org/bin/bitcoin-core-0.17.0/bitcoin-0.17.0-x86_64-linux-gnu.tar.gz
  # note: checksum below fetched from gpg-signed https://bitcoincore.org/bin/bitcoin-core-0.17.0/SHA256SUMS.asc
  echo "9d6b472dc2aceedb1a974b93a3003a81b7e0265963bd2aa0acdcb17598215a4f  bitcoin-0.16.1-x86_64-linux-gnu.tar.gz" | sha256sum -c -
}

[ -d ~/.bitcoin ] || {
  echo "Copying .bitcoin.."
  cp -r ~/conf/.bitcoin ~/
}

# todo: bitcoin-cli can't connect since tcp/8332 to localhost is blocked by iptables:
# kernel: Dropped outbound packet: IN= OUT=lo SRC=127.0.0.1 DST=127.0.0.1 LEN=52 TOS=0x00 PREC=0x00 TTL=64 ID=42742 DF PROTO=TCP SPT=40892 DPT=8332 WINDOW=43690 RES=0x00 SYN URGP=0 UID=1000 GID=1000

# todo: report bug, when Ctrl-C'ing the bitcoin-qt window, popup saying "Bitcoin Core is ready" appears
