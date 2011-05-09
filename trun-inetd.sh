#!/bin/sh
STR_INIT_OK="Initialization.Sequence.Completed"
MY_TESTNAME=${0##*run-}
MY_TESTNAME=${MY_TESTNAME%.sh}

main() {
action=$1;shift
case "$action" in
	plan)
		echo "test_define  $MY_TESTNAME-v4"
		echo "test_bg_prev $0 0 v4"
		echo "test_bg_prev $0 1 v4"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"

		echo "test_define  $MY_TESTNAME-v6"
		echo "test_bg_prev $0 0 v6"
		echo "test_bg_prev $0 1 v6"
		echo "test_egrep 30 $STR_INIT_OK"
		echo "test_cleanup $0 k"
		;;
	0) 	run_0 "$@";;
	1)	run_1 "$@";;
	k)	run_k "$@";;
esac
}

get_xinetd_conf() {
	local user=$1 flags=$2 port=$3 server=$4 server_args="$5"
	echo "service openvpn_test
{
	disable         = no
	type            = UNLISTED
	socket_type     = stream
	protocol        = tcp
	wait            = yes
	user            = $user
	flags           = $flags
	port            = $port
	server 		= $server
	server_args     = $server_args
}
"
}
get_inetd_conf() {
	local user=$1 flags=$2 port=$3 server=$4 server_args="$5"
	case $flags in IPv4) proto=tcp4;; IPv6) proto=ipv6;; esac
	echo $port stream $proto wait $user $server ${server##*/} $server_args
}
inetd_serverargs="--inetd wait --dev null --mode p2p --verb 3 --secret $PWD/../keys/openvpn.key"
run_0() {
  local vopt=${1?} # v4 xor v6
  test -x /usr/sbin/xinetd && {
    local conffile=$HOME/tmp/$USER-test-cfg-xinetd.$vopt.conf
    get_xinetd_conf $USER IP$vopt 5011 ${OPENVPN?} \
	  "$inetd_serverargs --proto tcp-server --log /dev/fd/2" > $conffile
    set -x
    exec /usr/sbin/xinetd -dontfork -f $conffile -filelog /dev/fd/2
  } || {
    local conffile=$HOME/tmp/$USER-test-cfg-inetd.$vopt.conf
    get_inetd_conf $USER IP$vopt 5011 ${OPENVPN?} \
	  "$inetd_serverargs --proto tcp-server --log /dev/fd/2" > $conffile
    set -x
    exec /usr/sbin/inetd -d $conffile
  }
}
run_1() {
  local vopt=${1?}
  case $vopt in v4) p=tcp-client;; v6) p=tcp6-client;; esac
  set -x
  exec ${GDB} ${OPENVPN?} --dev null --proto $p --remote localhost --nobind --rport 5011 --secret ../keys/openvpn.key
}
run_k() {
  /bin/fuser -s -k -n tcp 5011
  pkill xinetd 2>/dev/null
  pkill inetd 2>/dev/null
}

main "$@"
