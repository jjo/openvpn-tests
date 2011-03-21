#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp6-client --remote ::ffff:127.0.0.1 --lport 5012 --rport 5011 --secret ../openvpn.key "$@"
