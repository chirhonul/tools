#!/bin/bash
#
# Install the Chrome browser.
#
set -eu

source /etc/amnesia-env
cd ${BIN_PATH}

[ -e google-chrome-stable_current_amd64.deb ] || {
  echo "Downloading google-chrome-stable.."
  torify curl -vLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  echo "229b35f0d41bbb6edd98ce4ab8305994a0f5cd1ac4d9817571f07365b2d1ad80 /mnt/bin/google-chrome-stable_current_amd64.deb" | sha256sum -c -
}

if ! google-chrome-stable 2>/dev/null; then
  echo "Installing google-chrome-stable.."
  # The first dpkg command below fails with the following:
  #  "google-chrome-stable depends on libappindicator3-1; however:
  #    Package libappindicator3-1 is not installed."
  # The 'apt-get -yf install' command fixes this, but adds some apt sources for dl.google.com
  # that won't resolve due to network traffic going via the SOCKS5 proxy, so we have to remove
  # the extra apt sources and re-install.
  sudo bash -c " \
    dpkg -i google-chrome-stable_current_amd64.deb || true && \
    apt-get -yf install && \
    apt-get -y update && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    rm /etc/apt/sources.list.d/google-chrome.list"
fi
