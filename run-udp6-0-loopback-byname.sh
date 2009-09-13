#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote ip6-localhost --port 5011 --secret ../openvpn.key "$@"
