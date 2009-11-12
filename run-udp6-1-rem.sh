#!/bin/sh -x
: ${REM6?}
XTRAS=""
case "${OPENVPN}" in *exe) XTRAS="$(dirname ${OPENVPN})/*.dll";; esac
rsync -Lva ${OPENVPN?} ../openvpn.key $XTRAS "[${REM6?}]":/tmp
openvpn_fname=${OPENVPN##*/}
ssh -t ${REM6?} "sh -c '/bin/fuser -k /tmp/${openvpn_fname}*;/tmp/${openvpn_fname} --verb 5 --dev null --proto udp6 --port 5010 --secret /tmp/openvpn.key --float $@'"
#ssh -t ${REM6?} "sudo sh -c '/bin/fuser -k /tmp/${openvpn_fname}*;/tmp/${openvpn_fname} --verb 5 --dev tun --proto udp6 --port 5010 --secret /tmp/openvpn.key --float --ifconfig 1.1.1.1 1.1.1.253 $@'"
