#
# Script for setting up newly booted Tails instance with packages and configuration.
#
set -euo pipefail

[ -e /tmp/.packages_installed_marker ] || {
  echo "Installing packages.."
  sudo bash -c " \
    apt-get -y update && \
    apt-get -y install adduser gcc ncdu nmon libc6-dev tmux"
  touch /tmp/.packages_installed_marker
}

[ -e /dev/mapper/unlocked ] || {
  echo "Unlocking LUKS volume.."
  sudo bash -c " \
    cryptsetup open --type plain /dev/disk/by-id/usb-PNY_USB_2.0_FD_0400000000013503-0:0-part3 unlocked && \
    mount /dev/mapper/unlocked /mnt"
}

if ! gpg -k | grep -q chinul; then
  echo "Adding GPG key.."
  gpg --import < /mnt/keys/chinul.key
fi

[ -e ~/src ] || {
  echo "Creating symlinks to /mnt/bin directory.."
  ln -s /mnt/src ~/
}

[ -e ~/bin ] || {
  echo "Creating symlink to /mnt/bin directory.."
  ln -s /mnt/bin ~/
}

[ -e ~/conf ] || {
  echo "Creating symlink to conf directory.."
  ln -s /mnt/src/github.com/chirhonul/conf ~/
}

[ -e ~/src/docs_clear ] || {
  echo "Creating ~/src/docs_clear.."
  mkdir -p ~/src/docs_clear
  gpg --out /tmp/docs.tar.gz --decrypt ~/src/github.com/chirhonul/docs/docs.tar.gz.asc
  tar xzfv /tmp/docs.tar.gz --strip-components=3
  mv docs_clear ~/src/
  srm /tmp/docs.tar.gz
}

[ -e ~/docs ] || {
  echo "Creating symlinks to docs directory.."
  ln -s /mnt/src/docs_clear ~/docs
}


if ! ssh-add -L | grep -q chirhonul; then
  # todo: step below could be automated further.
  echo "Decrypting github.com.txt.asc for SSH key.."
  gpg --decrypt /mnt/docs_crypt/github.com.txt.asc
  echo "Adding SSH key.."
  ssh-add /mnt/keys/chirhonul_github0_id_rsa
fi

[ -e ~/.gitconfig ] || {
  echo "Adding .gitconfig.."
  cp ~/conf/.gitconfig ~/
}

[ -e ~/.ssh/known_hosts ] || {
  echo "Copying ~/.ssh/known_hosts.."
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh/
  cp /mnt/known_hosts ~/.ssh/
}

[ -e /mnt/bin/go1.10.2.linux-amd64.tar.gz ] || {
  echo "Fetching go installation.."
  torify curl -vLo /mnt/bin/go1.10.2.linux-amd64.tar.gz https://golang.org/dl/go1.10.2.linux-amd64.tar.gz
  echo "4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff /mnt/bin/go1.10.2.linux-amd64.tar.gz" | sha256sum -c -
}

if ! go version 2>/dev/null; then
  echo "Installing go.."
  sudo tar -C /usr/local -xzf /mnt/bin/go1.10.2.linux-amd64.tar.gz
fi

[ -e /mnt/bin/google-chrome-stable_current_amd64.deb ] || {
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
    dpkg -i /mnt/bin/google-chrome-stable_current_amd64.deb || true && \
    apt-get -yf install && \
    apt-get -y update && \
    dpkg -i /mnt/bin/google-chrome-stable_current_amd64.deb && \
    rm /etc/apt/sources.list.d/google-chrome.list"
fi

cp ~/conf/.bashrc ~/

echo "Done."
