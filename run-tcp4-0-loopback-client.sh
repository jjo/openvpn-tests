#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto tcp-client --remote localhost --rport 5011 --secret ../openvpn.key "$@"
