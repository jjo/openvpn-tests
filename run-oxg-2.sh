#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?}  --dev tun --proto udp --remote localhost --lport 5020 --rport 1194 --secret ../openvpn.key --ifconfig 1.1.1.2 1.1.1.1 "$@"
