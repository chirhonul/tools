if ! grep -q CookieAuthFile /etc/tor/torrc; then
	# sudo bash -c "echo 'CookieAuthFile /etc/tor/control_auth_cookie' >> /etc/tor/torrc"
	sudo systemctl restart tor@default.service
	sleep 5
fi
# todo: add user to debian-tor group
sudo chown $(id -u):$(id -g) /run/tor/control.authcookie
if [[ ! -e /opt/Bisq/Bisq ]]; then
    sudo dpkg -i Bisq-64bit-1.1.1.deb
fi
if [[ ! -e ~/.local/share/Bisq ]]; then
    cp -vr ~/docs.Bisq-backup/ ~/.local/share/Bisq/
fi
# /opt/Bisq/Bisq --torControlPort=9052 --torControlCookieFile=/etc/tor/control_auth_cookie
/opt/Bisq/Bisq --torControlPort=9052 --torControlCookieFile=/run/tor/control.authcookie
