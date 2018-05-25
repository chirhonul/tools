#!/bin/sh
#
# Install the digitalbitbox app.
#
cd /mnt

echo "Installing dependencies.."
sudo bash -c " \
  apt-get install -y build-essential libtool autotools-dev automake autoconf pkg-config git && \
  apt-get install -y libusb-1.0-0-dev libcurl4-openssl-dev libqrencode-dev && \
  apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libqt5websockets5-dev libavahi-compat-libdnssd-dev"
# TODO: following fails with:
#  libudev-dev : Depends: libudev1 (= 232-25+deb9u2) but 237-3~bpo9+1 is to be installed
# E: Unable to correct problems, you have held broken packages.
sudo apt-get install -y libudev-dev
echo "Cloning sources.."
mkdir -p src/github.com/digitalbitbox

# TODO: Submit patch to remove references to non-existing fix_qt_pkgconfig.patch in
# depends/packages/qt.mk.
cd src/github.com/digitalbitbox/
git clone https://github.com/digitalbitbox/dbb-app
mkdir -p deps-cache/sources/
cd dbb-app/depends/
torify make -j4 BASE_CACHE=$(pwd)/../../deps-cache/ SOURCES_PATH=$(pwd)/../../deps-cache/
cd ..
./autogen.sh
# TODO: following fails due to install issues with libudev.
# Trying to downgrade libudev1 with:
# $ sudo apt-get install libudev1=232-25+deb9u2
# Leads to:
# dpkg: udev: dependency problems, but removing anyway as you requested:
#  rng-tools depends on udev (>= 0.053) | makedev (>= 2.3.1-77); however:
#   Package udev is to be removed.
#   Package makedev is not installed.
#  libsane:amd64 depends on udev | makedev; however:
#   Package udev is to be removed.
#   Package makedev is not installed.
sudo apt-get -y install makedev
sudo apt-get install libudev1=232-25+deb9u2
sudo apt-get install libudev-dev
./configure --prefix=$(pwd)/depends/x86_64-pc-linux-gnu --enable-debug --with-gui=qt5
make
