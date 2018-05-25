#!/bin/sh
#
# Install docker.
#
set -eu

cd /mnt/bin

sudo apt-get -y install apparmor

[ -e docker-18.03.1-ce.tgz ] || {
  echo "Downloading docker.."
  torify curl -vLO https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz
  echo "0e245c42de8a21799ab11179a4fce43b494ce173a8a2d6567ea6825d6c5265aa docker-18.03.1-ce.tgz" | sha256sum -c -
}

if ! which docker 2>/dev/null; then
  echo "Installing docker.."
  sudo tar -C /usr/local -xzf docker-18.03.1-ce.tgz
fi

# sudo adduser docker --disabled-password
# sudo sh -c "export PATH=$PATH:/usr/local/docker; /usr/local/docker/dockerd"
