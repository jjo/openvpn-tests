#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote ::ffff:127.0.0.1 --port 5011 --secret ../keys/openvpn.key "$@"
