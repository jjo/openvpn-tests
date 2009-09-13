#!/bin/sh -x
: ${OPENVPN:=./openvpn}
${GDB} ${OPENVPN?} --dev tun --proto udp --float --port 5011 --secret ../openvpn.key --ifconfig 1.1.1.1 1.1.1.253
