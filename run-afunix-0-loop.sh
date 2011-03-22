#!/bin/sh -x
: ${OPENVPN?}
rm -fv /tmp/o.s
${GDB} ${OPENVPN?} --proto unix-dgram --local /tmp/o.s --remote /tmp/o.s --dev tun --ifconfig 1.1.1.1 1.1.1.2 --secret ../keys/openvpn.key $*
