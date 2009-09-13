#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp6-client --remote ip6-localhost --rport 5011 --secret ../openvpn.key "$@"
