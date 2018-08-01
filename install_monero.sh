#!/bin/bash
#
# Install Monero full node.
#
set -eu

cd ~/bin

[ -e ~/bin/monero-v0.12.2.0 ] || {
  echo "Downloading monero.."
  torify wget https://downloads.getmonero.org/cli/linux64
  echo "cb97e3f8b700a81e1b0f1a77509eefbfb415aa6013f23685f8933b559309c580  ~/bin/monero-v0.12.2.0.tar.gz" | sha256sum -c -
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

