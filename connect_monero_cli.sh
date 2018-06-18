#!/bin/sh

cd /mnt/keys
TOR_SVC=$(sudo cat /var/lib/tor/hidden_service/hostname)
torsocks /data/monero-v0.12.2.0/monero-wallet-cli --daemon-host ${TOR_SVC}
