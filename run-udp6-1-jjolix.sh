#!/bin/sh -x
rsync -Lva ${OPENVPN?} ../openvpn.key jjolix:/tmp
openvpn_fname=${OPENVPN##*/}
ssh -t jjolix "sudo sh -c '/bin/fuser -k /tmp/${openvpn_fname};/tmp/${openvpn_fname} --verb 5 --dev tun --proto udp6 --port 5010 --secret /tmp/openvpn.key --float --ifconfig 1.1.1.1 1.1.1.253 $@; sleep 20;/bin/fuser -k /tmp/${openvpn_fname}'"
