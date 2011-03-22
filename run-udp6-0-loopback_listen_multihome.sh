#!/bin/sh -x
xtra_ip6=fd00::caca:dede:fafa
case `hostname` in
  wolfman.devio.us)
	xtra_ip6=fe80::211:43ff:fe37:90e4%gif0 
	ip6=2001:470:4:2a5::2
	;;
  *)
	while read iface ip6;do 
		case $iface in wlan*|eth*) ;; *) continue;; esac
		#placeholder for more iface selection logic
		echo "$0: using: $iface $ip6" >/dev/tty;break
	done <<EOF
$(/sbin/ip -o -6 a | sed -nr '/fe80/s/^[0-9]+: ([a-z0-9]+).*(fe80::[0-9a-z:]+).*/\1 \2/p')
EOF
	(echo == /sbin/ip -6 ad ad $xtra_ip6/128 dev $iface ) >/dev/tty
	;;
esac
${GDB} ${OPENVPN?} --dev null --multihome --proto udp6 --local :: --port 5011 --secret ../keys/openvpn.key "$@"
