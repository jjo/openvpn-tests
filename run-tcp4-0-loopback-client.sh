#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto tcp-client --remote localhost --lport 5012 --rport 5011 --secret ../openvpn.key "$@"
