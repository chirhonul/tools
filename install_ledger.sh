#!/bin/sh
#
# Install dependencies to use Ledger Nano S.
#
cd /mnt

echo "Installing dependencies.."
sudo bash -c " \
  apt install -y --install-recommends python3-pip && \
  apt install -y cython3 && \
  apt install -y libusb-1.0-0-dev && \
  apt install -y libudev-dev=237-3~bpo9+1"

[ -e ~/src/github.com/trezor/cython-lidapi ] || {
  mkdir -p ~/src/github.com/trezor
  git clone --recursive https://github.com/trezor/cython-hidapi.git ~/src/github.com/trezor/cython-hidapi
}

[ -e ~/src/github.com/LedgerHQ/btchip-python ] || {
  mkdir -p ~/src/github.com/LedgerHQ
  git clone https://github.com/LedgerHQ/btchip-python.git ~/src/github.com/LedgerHQ/btchip-python
}

sudo bash -c "\
  pip3 install --user /mnt/src/github.com/trezor/cython-hidapi/ && \
  pip3 install --user /mnt/src/github.com/LedgerHQ/btchip-python/"

echo "Adding udev rules.."
sudo bash -c " \
  cp /mnt/src/github.com/chirhonul/conf/61-ledger.rules /lib/udev/rules.d/ && \
  chmod 644 /lib/udev/rules.d/61-ledger.rules && \
  udevadm control --reload-rules && \
  udevadm trigger"


