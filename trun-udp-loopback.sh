#!/bin/sh
STR_INIT_OK="Initialization.Sequence.Completed"
STR_INIT_OK_MUL="Peer.Connection.Initiated.with.*via"

MY_TESTNAME=${0##*run-}
MY_TESTNAME=${MY_TESTNAME%.sh}

main() {
action=$1;shift
case "$action" in
	plan)
		echo "test_define  $MY_TESTNAME-v4-byip"
		echo "test_bg_prev $0 0 v4 byip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v4-bynm"
		echo "test_bg_prev $0 0 v4 bynm"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-byip"
		echo "test_bg_prev $0 0 v6 byip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-bynm"
		echo "test_bg_prev $0 0 v6 bynm"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-mapped"
		echo "test_bg_prev $0 0 v6 mapp"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-native4"
		echo "test_bg_prev $0 0 v6 lone"
		echo "test_bg_prev $0 0 v4 tov6"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-multihome"
		echo "test_bg_prev $0 0 v6 lmul"
		echo "test_bg_prev $0 0 v6 cmul"
		echo "test_egrep 30 $STR_INIT_OK_MUL"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v4-multihome"
		echo "test_bg_prev $0 0 v4 lmul"
		echo "test_bg_prev $0 0 v4 cmul"
		echo "test_egrep 30 $STR_INIT_OK_MUL"
		echo "test_cleanup $0 k"
		;;
	0) 	run_0 "$@";;
	k)	run_k "$@";;
esac
}

set_ip6s(){
  xtra_ip6=fd00::caca:dede:fafa
  case `hostname` in
    *devio.us)
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
  	;;
  esac
}

run_0() {
  local vopt_nopt=${1?}-${2?} # {v4,v6}-{byip,bynm}
xopts=
case `uname -s` in FreeBSD) xopts="--float";;esac

  localhost6=ip6-localhost;case "$(uname -s)" in *BSD) localhost6=localhost;esac
xtra_ip=127.0.0.2
case `hostname` in wolfman*) xtra_ip=10.0.1.10;;tornado*) xtra_ip=192.168.1.25;;esac
  case $vopt_nopt in 
    v4-byip) opt="--proto udp  --remote 127.0.0.1        --port 5011 $xopts";;
    v4-bynm) opt="--proto udp  --remote localhost        --port 5011 $xopts";;
    v4-tov6) opt="--proto udp  --remote 127.0.0.1        --rport 5011 --nobind";;
    v6-byip) opt="--proto udp6 --remote ::1              --port 5011";;
    v6-bynm) opt="--proto udp6 --remote $localhost6      --port 5011";;
    v6-mapp) opt="--proto udp6 --remote ::ffff:127.0.0.1 --port 5011";;
    v6-lone) opt="--proto udp6                           --port 5011";;
    v6-lmul) opt="--proto udp6 --local ::                       --port 5011 --multihome";;
    v6-cmul) set_ip6s
	     opt="--proto udp6 --local $xtra_ip6 --remote $ip6  --rport 5011 --multihome";;
    v4-lmul) opt="--proto udp  --local $xtra_ip                 --port 5011 --multihome";;
    v4-cmul) opt="--proto udp  --local 127.0.0.1 --remote $xtra_ip --lport 5012 --rport 5011 --multihome";;
  esac
  ${GDB} ${OPENVPN?} --dev null --secret ../keys/openvpn.key $opt
}
run_k() {
  /bin/fuser -s -k -n tcp 5011
}

main "$@"
