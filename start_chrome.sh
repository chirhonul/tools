#!/bin/sh
#
# Run google chrome configured to use SOCKS5 proxy.
#
set -eu

google-chrome-stable --proxy-server="socks5://localhost:9150" --host-resolver-rules="MAP * ~NOTFOUND ,EXCLUDE localhost"
