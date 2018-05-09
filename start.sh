#
# Script for setting up newly booted Tails instance with stuff we need.
#
echo "Installing packages.."
sudo bash -c " \
  apt-get -y update && \
  apt-get -y install tmux"
