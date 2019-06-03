#!/bin/bash
#
# Install Monero full node.
#
set -eu

cd ~/bin

[ -e ~/bin/monero-gui-v0.14.0.0 ] || {
  echo "Downloading monero.."
  torify wget https://downloads.getmonero.org/cli/linux64
  echo "a3d73a6fe1729c7d31e9c599849fd48e0eaa0c7c80c2e7238bf6a5b4cf467b29  ~/bin/monero-gui-linux-x64-v0.14.0.0.tar" | sha256sum -c -
}

if ! grep -q 'HiddenServicePort 18081' /etc/tor/torrc; then
  echo "Configuring tor hidden service.."
  sudo bash -c ' \
    echo "HiddenServiceDir /var/lib/tor/hidden_service/" >> /etc/tor/torrc && \
    echo "HiddenServicePort 18081 127.0.0.1:18081" >> /etc/tor/torrc && \
    systemctl restart tor && \
    echo "Tor hidden service:" && \
    sleep 5 && \ # hack to allow async systemd restart above to take effect
    cat /var/lib/tor/monerod/hostname'
fi

