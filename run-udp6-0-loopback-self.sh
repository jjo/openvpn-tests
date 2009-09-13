#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote ::1 --port 5011 --secret ../openvpn.key "$@"
