#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp6-client --remote ip6-localhost --lport 5012 --rport 5011 --secret ../openvpn.key "$@"
