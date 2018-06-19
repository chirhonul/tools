#!/bin/sh
#
# Install the Oracle flavor of Java.
#
set -eu

source /etc/amnesia-env
cd ${BIN_PATH}

[ -e jdk-8u172-linux-x64.tar.gz ] || {
  echo "Downloading java.."
  torify wget http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"
  echo "28a00b9400b6913563553e09e8024c286b506d8523334c93ddec6c9ec7e9d346 jdk-8u172-linux-x64.tar.gz" | sha256sum -c -
}

if ! which java 2 >/dev/null; then
  echo "Installing java.."
  [ -d /usr/lib/jvm/ ] || {
    sudo bash -c " \
      mkdir -p /usr/lib/jvm/ && \
      cp jdk-8u172-linux-x64.tar.gz /usr/lib/jvm/ && \ 
      cd /usr/lib/jvm/ && \
      tar xzfv jdk-8u172-linux-x64.tar.gz && \
      chown -R amnesia:amnesia /usr/lib/jvm/" # todo: less wide ownership of dir would be nice.
  }
fi

# todo: may need to do some JCE policy stuff here.
# todo: install intellij and gradle too?
