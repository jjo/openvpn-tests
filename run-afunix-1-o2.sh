#!/bin/sh -x
${GDB} ${OPENVPN?} --proto unix-dgram --local /tmp/o2.s --remote /tmp/o1.s --dev tun --ifconfig 1.1.1.2 1.1.1.1 --secret ../openvpn.key $*
