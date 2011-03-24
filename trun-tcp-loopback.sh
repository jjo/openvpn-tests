#!/bin/sh
STR_INIT_OK="Initialization.Sequence.Completed"
MY_TESTNAME=${0##*run-}
MY_TESTNAME=${MY_TESTNAME%.sh}

main() {
action=$1;shift
case "$action" in
	plan)
		echo "test_define  $MY_TESTNAME-v4-byip"
		echo "test_bg_prev $0 0 v4 l_ip"
		echo "test_bg_prev $0 0 v4 c_ip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-byip"
		echo "test_bg_prev $0 0 v6 l_ip"
		echo "test_bg_prev $0 0 v6 c_ip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-bynm"
		echo "test_bg_prev $0 0 v6 l_nm"
		echo "test_bg_prev $0 0 v6 c_nm"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-mappedv4"
		echo "test_bg_prev $0 0 v6 l_ip"
		echo "test_bg_prev $0 0 v6 mapp"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-nativev4"
		echo "test_bg_prev $0 0 v6 l_ip"
		echo "test_bg_prev $0 0 v4 c_ip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		;;
	0) 	run_0 "$@";;
	k)	run_k "$@";;
esac
}


run_0() {
  local vopt_nopt=${1?}-${2?} # {v4,v6}-{byip,bynm}
  localhost6=ip6-localhost;case "$(uname -s)" in *BSD) localhost6=localhost;esac
  case $vopt_nopt in 
    v4-l_ip) opt="--proto tcp-server  --local  127.0.0.1   --lport 5011";;
    v4-c_ip) opt="--proto tcp-client  --remote 127.0.0.1   --rport 5011 --nobind";;
    v6-l_ip) opt="--proto tcp6-server --local  ::          --lport 5011";;
    v6-l_nm) opt="--proto tcp6-server --local  $localhost6 --lport 5011";;
    v6-c_ip) opt="--proto tcp6-client --remote ::1         --rport 5011 --nobind";;
    v6-c_nm) opt="--proto tcp6-client --remote $localhost6 --rport 5011 --nobind";;
    v6-mapp) opt="--proto tcp6-client --remote ::ffff:127.0.0.1 --rport 5011 --nobind";;
  esac
  ${GDB} ${OPENVPN?} --dev null --secret ../keys/openvpn.key $opt
}
run_k() {
  /bin/fuser -s -k -n tcp 5011
}

main "$@"
