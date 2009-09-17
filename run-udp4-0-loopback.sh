#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto udp --remote localhost --port 5011 --secret ../openvpn.key "$@"
