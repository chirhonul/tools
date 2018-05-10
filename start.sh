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
    cryptsetup open --type plain /dev/sdb3 unlocked && \
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
  echo "Creating symlinks to /mnt/docs directory.."
  ln -s /mnt/docs ~/
}

[ -e ~/bin ] || {
  echo "Creating symlink to /mnt/bin directory.."
  ln -s /mnt/bin ~/
}

[ -e ~/.ssh/known_hosts ] || {
  echo "Copying ~/.ssh/known_hosts.."
  cp /mnt/known_hosts ~/.ssh/
}

echo "Done."
