#!/bin/sh -x
: ${REM6?}
sudo ${GDB} ${OPENVPN?} --dev tun --proto tcp6-client --remote "$REM6" --rport 5010 --secret ../openvpn.key --ifconfig 1.1.1.253 1.1.1.1 "$@"
