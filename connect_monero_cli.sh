#!/bin/sh

cd ~/keys/
TOR_SVC=$(sudo cat /var/lib/tor/monerod/hostname)
torsocks ~/bin/monero-gui-v0.14.0.0/monero-wallet-cli --daemon-host ${TOR_SVC}
