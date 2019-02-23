#!/bin/bash
#
# Install Monero full node.
#
set -eu

cd ~/bin

[ -e ~/bin/monero-v0.13.0.4 ] || {
  echo "Downloading monero.."
  torify wget https://downloads.getmonero.org/cli/linux64
  echo "693e1a0210201f65138ace679d1ab1928aca06bb6e679c20d8b4d2d8717e50d6  ~/bin/monero-linux-x64-v0.13.0.4.tar.bz2" | sha256sum -c -
}

if ! grep -q 'HiddenServicePort 18081' /etc/tor/torrc; then
  echo "Configuring tor hidden service.."
  sudo bash -c ' \
    echo "HiddenServiceDir /var/lib/tor/hidden_service/" >> /etc/tor/torrc && \
    echo "HiddenServicePort 18081 127.0.0.1:18081" >> /etc/tor/torrc && \
    systemctl restart tor && \
    echo "Tor hidden service:" && \
    sleep 5 && \ # hack to allow async systemd restart above to take effect
    cat /var/lib/tor/hidden_service/hostname'
fi

