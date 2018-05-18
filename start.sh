#
# Script for setting up newly booted Tails instance with stuff we need.
#

[ -e /tmp/.packages_installed_marker ] || {
  echo "Installing packages.."
  sudo bash -c " \
    apt-get -y update && \
    apt-get -y install tmux"
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

[ -e ~/.gitconfig ] || {
  echo "Adding .gitconfig.."
  cp /mnt/src/.gitconfig ~/
}

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

[ -e ~/.ssh/known_hosts ] || {
  echo "Copying ~/.ssh/known_hosts.."
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh/
  cp /mnt/known_hosts ~/.ssh/
}

echo "Done."
