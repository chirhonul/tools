#!/bin/sh
#
# Set up TigerVNC connection to remote server.
#
set -eu

# Set up SSH tunnel to remote host on 127.0.0.1/5900.
ssh -L 8888:127.0.0.1:5900 -N -l amnesia s0

# Whitelist the 127.0.0.1 tcp/8888 -> tcp/5900 traffic (otherwise denied by default on Tails).
iptables -I OUTPUT -o lo -p tcp --sport 8888 --dport 5900 -s 127.0.0.1/32 -d 127.0.0.1/32 -j ACCEPT

# On server side, start with:
# vncserver -depth 24 -geometry 1600x1200 :0
# The :0 means that tcp/5900 is used. Kill with:
# vncserver -kill :0
