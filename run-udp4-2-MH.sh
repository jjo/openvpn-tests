#!/bin/sh -x
#pass --local ADDR --remote ADDR
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?} --dev tun --proto udp --port 5011 --secret ../openvpn.key --ifconfig-noexec "$@"
