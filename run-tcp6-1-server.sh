#!/bin/sh -x
: ${REM6?}
rsync -Lva ${OPENVPN?} ../openvpn.key ${REM6?}:/tmp
openvpn_fname=${OPENVPN##*/}
ssh -t ${REM6?} "sudo sh -c '/bin/fuser -k /tmp/${openvpn_fname}*;/tmp/${openvpn_fname} --verb 3 --dev tun --proto tcp6-server --port 5010 --secret /tmp/openvpn.key --float --ifconfig 1.1.1.1 1.1.1.253 $@'"
