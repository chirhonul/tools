#!/usr/bin/env bash

# todo: add user to debian-tor group
sudo chown $(id -u):$(id -g) /run/tor/control.authcookie
if [[ ! -e /opt/Bisq/Bisq ]]; then
	sudo dpkg -i ~/bin/Bisq-64bit-1.1.1.deb
fi
if [[ ! -e ~/.local/share/Bisq ]]; then
	mkdir -p ~/.local/share
	cp -vr ~/docs/Bisq-backup/ ~/.local/share/Bisq/
fi
# /opt/Bisq/Bisq --torControlPort=9052 --torControlCookieFile=/etc/tor/control_auth_cookie
/opt/Bisq/Bisq --torControlPort=9052 --torControlCookieFile=/run/tor/control.authcookie
