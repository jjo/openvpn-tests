#!/bin/sh
STR_INIT_OK="Initialization.Sequence.Completed"
MY_TESTNAME=${0##*run-}
MY_TESTNAME=${MY_TESTNAME%.sh}

main() {
action=$1;shift
case "$action" in
	plan)
		echo "test_define  $MY_TESTNAME-v4-byip"
		echo "test_bg_prev $0 1 v4 byip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v4-bynm"
		echo "test_bg_prev $0 1 v4 bynm"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-byip"
		echo "test_bg_prev $0 1 v6 byip"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-bynm"
		echo "test_bg_prev $0 1 v6 bynm"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-mapped"
		echo "test_bg_prev $0 1 v6 mapp"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6-native4"
		echo "test_bg_prev $0 0 v6"
		echo "test_bg_prev $0 1 v4 mapp"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"
		;;
	1) 	run_1 "$@";;
	k)	run_k "$@";;
esac
}

run_1() {
  local vopt_nopt=${1?}-${2?} # {v4,v6}-{byip,bynm}
  localhost6=ip6-localhost;case "$(uname -s)" in *BSD) localhost6=localhost;esac
  case $vopt_nopt in 
    v4-byip) p=udp ;remote=127.0.0.1;;
    v4-bynm) p=udp ;remote=localhost;;
    v4-tov6) p=udp ;remote=127.0.0.1;; -- nobind --rport 5011
    v6-byip) p=udp6;remote=::1;;
    v6-bynm) p=udp6;remote=$localhost6;;
    v6-mapp) p=udp6;remote=::ffff:127.0.0.1;;
  esac
  ${GDB} ${OPENVPN?} --dev null --proto udp --remote 127.0.0.1 --nobind --rport 5011 --secret ../keys/openvpn.key "$@"
  ${GDB} ${OPENVPN?} --dev null --proto $p --remote $remote --port 5011 --secret ../keys/openvpn.key
}
run_0() {
  local vopt_nopt=${1?}-${2?} # {v4,v6}-{byip,bynm}
  case $vopt_nopt in 
    v6-*) p=udp6;;
  esac
  ${GDB} ${OPENVPN?} --dev null --proto $p --port 5011 --secret ../keys/openvpn.key "$@"
}
run_k() {
  /bin/fuser -s -k -n tcp 5011
}

main "$@"
