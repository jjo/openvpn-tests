#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?}  --dev null --proto tcp6-server --local :: --lport 5011 --secret ../openvpn.key "$@"
