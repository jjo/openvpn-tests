#!/bin/sh -x
${GDB} ${OPENVPN?} --dev null --multihome --local 127.0.0.2 --port 5011 --secret ../keys/openvpn.key "$@"
