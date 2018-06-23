#!/bin/bash
#
# Install tigervnc.
#
set -eu

echo "Installing vnc server.."
sudo apt-get -y update
sudo apt install -y xfce4 xfce4-goodies tightvncserver

echo "Done."
