#!/bin/sh -x
${GDB} ${OPENVPN?} --proto unix-dgram --local /tmp/o1.s --remote /tmp/o2.s --dev tun --ifconfig 1.1.1.1 1.1.1.2 --secret ../keys/openvpn.key $*
