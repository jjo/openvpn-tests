#!/bin/sh -x
REM6="fe80::20d:b9ff:fe14:e09c"
sudo ${GDB} ${OPENVPN?} --dev tun --proto udp6 --remote "$REM6" --port 5010 --secret ../openvpn.key --ifconfig 1.1.1.253 1.1.1.1 "$@"
