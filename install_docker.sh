#!/bin/bash
#
# Install docker.
#
set -eu

[ $(id -u) -eq 0 ] || {
  echo "failing; this script needs superuser powers"
  exit 1
}

source /etc/os-release

echo "Installing docker for ${ID}.."
apt-get install -y aptitude apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
if ! apt-key fingerprint 0EBFCD88 2>/dev/null | grep -q '9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88'; then
  echo 'failing; bad docker key fingerprint'
  exit 1
fi
add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/'${ID}' '$(lsb_release -cs)' stable'
apt-get -y update
aptitude -y install docker-ce
echo "Adding amnesia user in group docker.."
adduser --ingroup docker --shell /bin/bash --disabled-password amnesia
echo "Done."
