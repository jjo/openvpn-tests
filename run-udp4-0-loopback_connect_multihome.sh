#!/bin/sh -x
xtra_ip=127.0.0.2
case `hostname` in wolfman.devio.us) xtra_ip=10.0.1.10;;esac
${GDB} ${OPENVPN?} --dev null --multihome --local 127.0.0.1 --remote $xtra_ip --lport 5012 --rport 5011 --secret ../keys/openvpn.key "$@"
