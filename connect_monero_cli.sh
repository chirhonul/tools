#!/bin/sh

cd ~/keys/
TOR_SVC=$(sudo cat /var/lib/tor/hidden_service/hostname)
torsocks ~/bin/monero-v0.13.0.4/monero-wallet-cli --daemon-host ${TOR_SVC}
