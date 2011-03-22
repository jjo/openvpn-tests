#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp-client --remote 127.0.0.1 --lport 5012 --rport 5011 --secret ../keys/openvpn.key "$@"
