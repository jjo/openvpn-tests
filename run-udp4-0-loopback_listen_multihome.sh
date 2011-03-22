#!/bin/sh -x
xtra_ip=127.0.0.2
case `hostname` in wolfman.devio.us) xtra_ip=10.0.1.10;;esac
${GDB} ${OPENVPN?} --dev null --multihome --local $xtra_ip --port 5011 --secret ../keys/openvpn.key "$@"
