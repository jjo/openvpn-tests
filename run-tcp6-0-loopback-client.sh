#!/bin/sh -x
${GDB} ${OPENVPN?}  --dev null --proto tcp6-client --remote ::1 --rport 5011 --secret ../openvpn.key "$@"
