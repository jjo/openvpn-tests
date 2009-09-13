#!/bin/sh -x
: ${OPENVPN?}
DEV=${1:?missing devname};shift
${GDB} ${OPENVPN?} --dev tun --proto udp6 --remote fe80::5054:ff:fe12:3456%$DEV --port 5010 --secret ../openvpn.key --ifconfig  1.1.1.1 1.1.1.253 "$@"
