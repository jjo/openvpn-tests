#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto udp --remote 127.0.0.1 --nobind --rport 5011 --secret ../keys/openvpn.key "$@"
