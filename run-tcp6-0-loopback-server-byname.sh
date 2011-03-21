#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp6-server --local ip6-localhost --lport 5011 --secret ../keys/openvpn.key "$@"
