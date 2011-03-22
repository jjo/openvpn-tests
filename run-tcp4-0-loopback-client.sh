#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto tcp-client --remote localhost --nobind --rport 5011 --secret ../keys/openvpn.key "$@"
