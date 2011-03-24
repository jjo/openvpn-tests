#!/bin/sh
STR_INIT_OK="Initialization.Sequence.Completed"
STR_INIT_OK_MUL="Peer.Connection.Initiated.with.*via"

MY_TESTNAME=${0##*run-}
MY_TESTNAME=${MY_TESTNAME%.sh}

main() {
action=$1;shift
case "$action" in
	plan)
		echo "test_define  $MY_TESTNAME-udp6"
		echo "test_bg_prev $0 0 udp6 rem_l"
		echo "test_bg_prev $0 0 udp6 loc_c"
		echo "test_egrep 60 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-tcp6"
		echo "test_bg_prev $0 0 tcp6 rem_l"
		echo "test_bg_prev $0 0 tcp6 loc_c"
		echo "test_egrep 60 $STR_INIT_OK"
		echo "test_cleanup $0 k"
		;;

	0) 	run_0 "$@";;
	k)	run_k "$@";;
esac
}

remote_prepare() {
XTRAS=""
case "${OPENVPN}" in *exe) XTRAS="$(dirname ${OPENVPN})/*.dll";; esac
#rsync -Lva ${OPENVPN?} ../keys/openvpn.key $XTRAS "[${REM6?}]":/tmp
}
remote_check() {
jjolix6=2a01:198:200:7c8::1
export REM6
if ping6 -q -c1 -w1 $jjolix6;then
  REM6="$jjolix6"
elif fping jjolix;then
  DEV="$(/sbin/ip r get fe80::1 | sed -r -n 's/.* dev ([^ ]+).*/\1/p')"
  REM6="fe80::20d:b9ff:fe14:e09c%$DEV"
#else
#  REM6=2002:5449:2ce5:2:20d:b9ff:fe14:e09c
else
  return 1
fi

}

run_0() {
	remote_check||return 1
: ${REM6?}
  local vopt_nopt=${1?}-${2?} # {v4,v6}-{byip,bynm}
  case $vopt_nopt in 
    udp6-rem_l)
	openvpn_fname=${OPENVPN##*/}
	ssh -t ${REM6?} "sh -c '/bin/fuser -k /tmp/${openvpn_fname}*;
	tmp/${openvpn_fname} --dev null --secret /tmp/openvpn.key --verb 5
                     --proto udp6        --port 5010 --float'"
	return $?;;
    tcp6-rem_l)
	openvpn_fname=${OPENVPN##*/}
	ssh -t ${REM6?} "sh -c '/bin/fuser -k /tmp/${openvpn_fname}*;
	tmp/${openvpn_fname} --dev null --secret /tmp/openvpn.key --verb 5
                     --proto tcp6-server --port 5010 --float'"
	return $?;;
	
    udp6-loc_c) opt="--proto udp6        --remote $REM6 --nobind --rport 5010";;
    tcp6-loc_c) opt="--proto tcp6-client --remote $REM6 --nobind --rport 5010";;
  esac
  ${GDB} ${OPENVPN?} --dev null --secret ../keys/openvpn.key $opt
}
run_k() {
  /bin/fuser -s -k -n tcp 5010
}

main "$@"
