#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp6-client --remote ::1 --nobind --rport 5011 --secret ../keys/openvpn.key "$@"
