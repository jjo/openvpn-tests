#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp-server --remote localhost --lport 5011 --secret ../openvpn.key "$@"
