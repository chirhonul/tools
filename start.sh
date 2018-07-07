#
# Script for setting up newly booted Tails instance with packages and configuration.
#
set -euo pipefail

PATH=${PATH}:~/src/github.com/chirhonul/tools

echo "Checking if we can sudo without password.."
[ -e /etc/sudoers.d/user_sudo ] || {
  echo "Adding sudo right without password.."
  sudo bash -c ' \
    passwd -d amnesia && \
    echo "amnesia ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user_sudo'
}

[ -e /tmp/.packages_installed_marker ] || {
  echo "Installing packages.."
  sudo bash -c " \
    apt-get -y update && \
    apt-get -y install adduser expect gcc htop ncdu nmon mr libc6-dev tmux"
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

[ -e /etc/amnesia-env ] || {
  echo "Creating /etc/amnesia-env.."
  sudo bash -c ' \
    echo "BIN_PATH=/mnt/bin/" > /etc/amnesia-env && \
    chown $(id -u amnesia):$(id -g amnesia) /etc/amnesia-env'
}

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

[ -e ~/.gitconfig ] || {
  echo "Adding .gitconfig.."
  cp ~/conf/.gitconfig ~/
}

[ -e ~/.ssh ] || {
  echo "Copying ~/.ssh config.."
  cp -vr ~/docs/.ssh ~/
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

if ! sudo iptables-save | grep -q 8888; then
  echo "Adding iptables rule to allow vnc traffic on 127.0.0.1.."
  sudo iptables -I OUTPUT -o lo -p tcp --sport 8888 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
  sudo iptables -I OUTPUT -o lo -p tcp --sport 8889 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
  sudo iptables -I OUTPUT -o lo -p tcp --sport 8890 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
  sudo iptables -I OUTPUT -o lo -p tcp -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
fi

cp ~/conf/.bashrc ~/

# Copy the github.com/rsc/2fa file.
[ -e ~/.2fa ] || {
  echo "Adding .2fa file.."
  cp -v ~/docs/.2fa ~/
}

echo "Done."
