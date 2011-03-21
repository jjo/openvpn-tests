#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote ip6-localhost --port 5011 --secret ../keys/openvpn.key "$@"
