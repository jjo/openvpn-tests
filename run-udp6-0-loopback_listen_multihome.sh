#!/bin/sh -x
UNIQ_LOCAL_ADD=fc00::cabe:ceca:0123
while read iface ip6;do 
	case $iface in wlan*|eth*) ;; *) continue;; esac
	#placeholder for more iface selection logic
	echo "$0: using: $iface $ip6" >/dev/tty;break
done <<EOF
$(/sbin/ip -o -6 a | sed -nr '/fe80/s/^[0-9]+: ([a-z0-9]+).*(fe80::[0-9a-z:]+).*/\1 \2/p')
EOF
(echo == /sbin/ip -6 ad ad $UNIQ_LOCAL_ADD/128 dev $iface ) >/dev/tty
${GDB} ${OPENVPN?} --dev null --multihome --proto udp6 --local :: --port 5011 --secret ../keys/openvpn.key "$@"
