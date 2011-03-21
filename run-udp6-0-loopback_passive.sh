#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto udp6 --port 5011 --secret ../keys/openvpn.key "$@"
