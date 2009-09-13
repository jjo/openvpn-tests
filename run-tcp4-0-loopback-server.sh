#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?}  --dev null --proto tcp-server --remote localhost --lport 5011 --secret ../openvpn.key "$@"
