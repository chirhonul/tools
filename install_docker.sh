#!/bin/sh
#
# Install docker.
#
# Start with:
#   sudo adduser docker --disabled-password
#   sudo sh -c "export PATH=$PATH:/usr/local/docker:/sbin; dockerd"
# Pulling images via SOCKS5 proxy seems like it should work (but doesn't) with:
#   ALL_PROXY=socks5://localhost:9150 docker run alpine echo hi
# Unable to find image 'alpine:latest' locally
# /usr/local/docker/docker: Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp 127.0.0.1:9150: getsockopt: connection refused.
#
# Another option would be to ssh forward a socket to a remote docker host:
#   ssh -L ./mysock:/var/run/docker.sock -Nf hostname.example.com
#   DOCKER_HOST=unix://mysock docker ps
#
set -eu

cd /mnt/bin

[ -e docker-18.03.1-ce.tgz ] || {
  echo "Downloading docker.."
  torify curl -vLO https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz
  echo "0e245c42de8a21799ab11179a4fce43b494ce173a8a2d6567ea6825d6c5265aa docker-18.03.1-ce.tgz" | sha256sum -c -
}

if ! which docker 2>/dev/null; then
  echo "Installing docker.."
  sudo tar -C /usr/local -xzf docker-18.03.1-ce.tgz
fi

