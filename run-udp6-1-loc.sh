#!/bin/sh -x
: ${REM6?}
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote "$REM6" --port 5010 --secret ../keys/openvpn.key "$@"
#sudo ${GDB} ${OPENVPN?} --dev tun --proto udp6 --remote "$REM6" --port 5010 --secret ../keys/openvpn.key --ifconfig 1.1.1.253 1.1.1.1 "$@"
