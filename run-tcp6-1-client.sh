#!/bin/sh -x
: ${REM6?}
${GDB} ${OPENVPN?} --dev null --proto tcp6-client --remote "$REM6" --nobind --rport 5010 --secret ../keys/openvpn.key
#sudo ${GDB} ${OPENVPN?} --dev tun --proto tcp6-client --remote "$REM6" --rport 5010 --secret ../keys/openvpn.key --ifconfig 1.1.1.253 1.1.1.1 "$@"
