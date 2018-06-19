#!/bin/sh
#
# Install Bitcoin Core.
#
set -eu

cd /data


[ -e ~/bin/bitcoin-0.16.1-x86_64-linux-gnu.tar.gz ] || {
  echo "Downloading bitcoin.."
  torify wget https://bitcoincore.org/bin/bitcoin-core-0.16.1/bitcoin-0.16.1-x86_64-linux-gnu.tar.gz
  # note: checksum below fetched from gpg-signed https://bitcoincore.org/bin/bitcoin-core-0.16.1/SHA256SUMS.asc
  echo "10b31d17351ff4c7929cf955e4d24a2398b0ce91509f707faf8596940c12432a  bitcoin-0.16.1-x86_64-linux-gnu.tar.gz" | sha256sum -c -
}

[ -d ~/.bitcoin ] || {
  echo "Copying .bitcoin.."
  cp ~/conf/.bitcoin ~/
}

# todo: bitcoin-cli can't connect since tcp/8332 to localhost is blocked by iptables:
# kernel: Dropped outbound packet: IN= OUT=lo SRC=127.0.0.1 DST=127.0.0.1 LEN=52 TOS=0x00 PREC=0x00 TTL=64 ID=42742 DF PROTO=TCP SPT=40892 DPT=8332 WINDOW=43690 RES=0x00 SYN URGP=0 UID=1000 GID=1000

# todo: report bug, when Ctrl-C'ing the bitcoin-qt window, popup saying "Bitcoin Core is ready" appears
