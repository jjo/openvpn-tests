#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?}  --dev null --proto tcp6-server --local ip6-localhost --lport 5011 --secret ../openvpn.key "$@"
