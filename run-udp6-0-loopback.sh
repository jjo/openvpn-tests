#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote ::1 --port 5011 --secret ../keys/openvpn.key "$@"
