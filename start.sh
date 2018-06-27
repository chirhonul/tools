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

install_java() {
  cd ~/bin
  if which java 2>&1 >/dev/null; then
    echo "Java is already installed:"
    echo "$(javac -version)"
    return 0
  fi
  [ -d /usr/lib/jvm/ ] || {
    echo "Creating /usr/lib/jvm/.."
    sudo mkdir -p /usr/lib/jvm/
  }
  uid=$(id -u)
  gid=$(id -g)
  echo "Installing java for user:group ${uid}:${gid}.."
  sudo bash -c " \
    cp jdk-8u172-linux-x64.tar.gz /usr/lib/jvm/ && \
    cd /usr/lib/jvm/ && \
    tar xzfv jdk-8u172-linux-x64.tar.gz && \
    chown -R ${uid}:${gid} /usr/lib/jvm/" # TODO: less wide ownership of dir would be nice.
  echo "Java has been installed. You may want to add it to your PATH and specify JAVA_HOME:"
  echo 'echo export PATH=${PATH}:/usr/lib/jvm/jdk1.8.0_172/bin >> ~/.bashrc'
  echo 'echo export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_172 >> ~/.bashrc'
}

install_gradle() {
  cd ~/bin/
  if which gradle 2>&1 >/dev/null; then
    echo "Gradle is already installed:"
    echo "$(gradle -version)"
    return 0
  fi

  [ -d /opt/gradle/gradle-4.6 ] && {
    echo "Gradle is already installed:"
    echo "$(gradle -version)"
    echo "However it is not on PATH. You may want to add it to your PATH:"
    echo 'echo export PATH=$PATH:/opt/gradle/gradle-4.6/bin >> ~/.bashrc'
    return 0
  }
  echo "Installing gradle.."
  sudo bash -c " \
    mkdir -p /opt/gradle && \
    unzip -d /opt/gradle/ gradle-4.6-bin.zip && \
    chown -R $(id -u amnesia):$(id -g amnesia)"
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
  cp -v ~/docs/.ssh ~/
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

if ! sudo iptables-save | grep -q 8888; then
  echo "Adding iptables rule to allow vnc traffic on 127.0.0.1.."
  sudo iptables -I OUTPUT -o lo -p tcp --sport 8888 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
  sudo iptables -I OUTPUT -o lo -p tcp --sport 8889 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
  sudo iptables -I OUTPUT -o lo -p tcp --sport 8890 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
  sudo iptables -I OUTPUT -o lo -p tcp -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT
fi

cp ~/conf/.bashrc ~/
cp -r ~/docs/.IdeaIC2018.1 ~/

# Copy the github.com/rsc/2fa file.
[ -e ~/.2fa ] || {
  echo "Adding .2fa file.."
  cp -v ~/docs/.2fa ~/
}

install_java
install_gradle

echo "Done."
