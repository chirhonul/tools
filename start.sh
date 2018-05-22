#
# Script for setting up newly booted Tails instance with packages and configuration.
#

[ -e /tmp/.packages_installed_marker ] || {
  echo "Installing packages.."
  sudo bash -c " \
    apt-get -y update && \
    apt-get -y install gcc libc6-dev tmux"
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

if ! ssh-add -L | grep -q chirhonul; then
  echo "Adding SSH key.."
  ssh-add /mnt/keys/chirhonul_github0_id_rsa
fi

[ -e ~/src ] || {
  echo "Creating symlinks to /mnt/bin directory.."
  ln -s /mnt/src ~/
}

[ -e ~/docs ] || {
  echo "Creating symlinks to docs directory.."
  ln -s /mnt/src/github.com/chirhonul/docs ~/
}

[ -e ~/bin ] || {
  echo "Creating symlink to /mnt/bin directory.."
  ln -s /mnt/bin ~/
}

[ -e ~/conf ] || {
  echo "Creating symlink to conf directory.."
  ln -s /mnt/src/github.com/chirhonul/conf ~/
}

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

[ -e /tmp/docs_clear ] || {
  echo "Creating /tmp/docs_clear.."
  mkdir -p /tmp/docs_clear
  gpg --out /tmp/docs.tar.gz --decrypt ~/docs/docs.tar.gz.asc
  tar xzfv /tmp/docs.tar.gz
  mv docs_clear /tmp/
}

[ -e ~/src/go1.10.2.linux-amd64.tar.gz ] || {
  echo "Fetching go installation.."
  torify curl -vLo /mnt/src/go1.10.2.linux-amd64.tar.gz https://golang.org/dl/go1.10.2.linux-amd64.tar.gz
  echo "4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff /mnt/src/go1.10.2.linux-amd64.tar.gz" | sha256sum -c -
}

if ! go version 2>/dev/null; then
  echo "Installing go.."
  sudo tar -C /usr/local -xzf /mnt/src/go1.10.2.linux-amd64.tar.gz
fi

[ -e ~/src/google-chrome-stable_current_amd64.deb ] || {
  echo "Downloading google-chrome-stable.."
  torify curl -vLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  echo "229b35f0d41bbb6edd98ce4ab8305994a0f5cd1ac4d9817571f07365b2d1ad80 /mnt/src/google-chrome-stable_current_amd64.deb" | sha256sum -c -
}

if ! google-chrome-stable 2>/dev/null; then
  echo "Installing google-chrome-stable.."
  sudo dkpg -i google-chrome-stable_current_amd64.deb
  sudo apt --fix-broken install
  sudo dkpg -i google-chrome-stable_current_amd64.deb
fi
}

cp ~/conf/.bashrc ~/

echo "Done."
