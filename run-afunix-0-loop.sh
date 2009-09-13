#!/bin/sh -x
: ${OPENVPN:=./openvpn}
rm -fv /tmp/o.s
${GDB} ${OPENVPN?} --proto unix-dgram --local /tmp/o.s --remote /tmp/o.s --dev tun --ifconfig 1.1.1.1 1.1.1.2 --secret ../openvpn.key $*
