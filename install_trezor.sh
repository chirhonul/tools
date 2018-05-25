#!/bin/sh
#
# Install the trezord-go tool.
#
# Example usage:
# trezorctl ping hi
# trezorctl encrypt_keyvalue foo barbarbarbarbarb # value % 16 == 0 is required
# trezorctl decrypt_keyvalue foo b90e3ae05a3f371e834078554677cc78
#
set -eu

[ -e ~/bin/trezord-go ] || {
  echo "Installing trezord-go.."
  go get -v github.com/trezor/trezord-go
  go install -v github.com/trezor/trezord-go
}

echo "Adding udev rules.."
sudo bash -c " \
  cp /mnt/src/github.com/chirhonul/conf/51-trezor.rules /lib/udev/rules.d/ && \
  chmod 644 /lib/udev/rules.d/51-trezor.rules && \
  udevadm control --reload-rules && \
  udevadm trigger"
