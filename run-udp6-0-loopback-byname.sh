#!/bin/sh -x
localhost6=ip6-localhost
case "$(uname -s)" in *BSD) localhost6=localhost;esac
${GDB} ${OPENVPN?} --dev null --proto udp6 --remote $localhost6 --port 5011 --secret ../keys/openvpn.key "$@"
