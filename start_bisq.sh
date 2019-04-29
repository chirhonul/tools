if ! grep -q CookieAuthFile /etc/tor/torrc; then
	sudo bash -c "echo 'CookieAuthFile /etc/tor/control_auth_cookie' >> /etc/tor/torrc"
	sudo systemctl restart tor@default.service
	sleep 5
fi
sudo chown $(id -u):$(id -g) /etc/tor/torrc
/opt/Bisq/Bisq --torControlPort=9052 --torControlCookieFile=/etc/tor/control_auth_cookie
