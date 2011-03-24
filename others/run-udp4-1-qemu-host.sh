#!/bin/sh -x
${GDB} ${OPENVPN?} --dev tun --proto udp --float --port 5011 --secret ../keys/openvpn.key --ifconfig 1.1.1.1 1.1.1.253
