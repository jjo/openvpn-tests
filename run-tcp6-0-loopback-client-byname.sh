#!/bin/sh -x
localhost6=ip6-localhost
case "$(uname -s)" in *BSD) localhost6=localhost;esac
${GDB} ${OPENVPN?}  --dev null --proto tcp6-client --remote $localhost6 --lport 5012 --rport 5011 --secret ../keys/openvpn.key "$@"
