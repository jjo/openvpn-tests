#!/bin/sh -x
${GDB} ${OPENVPN?} --dev tun --proto udp --remote 10.0.2.2 --port 5011 --secret ../keys/openvpn.key --ifconfig 1.1.1.253 1.1.1.1
