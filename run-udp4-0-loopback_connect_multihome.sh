#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --multihome --remote 127.0.0.2 --rport 5011 --secret ../openvpn.key "$@"
