#!/bin/sh -x
: ${OPENVPN:=./openvpn}
case "$1" in
--freebsd) shift;set --   ed0 "$@";;
--openbsd) shift;set --   ne3 --dev tun0 "$@";;
esac
DEV=${1:?missing devname};shift
${GDB} ${OPENVPN?} --dev tun --proto udp6 --remote fe80::200:ff:fe00:1%$DEV --port 5010 --secret ../openvpn.key "$@" --ifconfig 1.1.1.253 1.1.1.1
