#!/bin/bash
# Crude but useful unittests for openvpn over ipv6/4
# Author: JuanJo Ciarlante
export LIBTEST_OUTPUT_DIR=/tmp

# my_env.sh should contain the following vars:
#   REM6="2002:5457:5de5:2:20d:b9ff:fe29:901a"
. ${0%/*}/my_env.sh || exit 1
. ${0%/*}/libtest.sh || exit 1

t=$LIBTEST_OUTPUT_DIR
tdir=${0%/*}

# no-op, just to document :)
: ${O_ARGS:=}
unset OPENVPN
BINNAME=openvpn-test-$USER
if [ -f openvpn ];then
  cp -p $PWD/openvpn $t/$BINNAME || exit 1
  export OPENVPN="$t/$BINNAME"
elif [ -f openvpn.exe ];then
  cp -p $PWD/openvpn.exe $t/$BINNAME.exe || exit 1
  export OPENVPN="$t/$BINNAME.exe"
else
  echo "./openvpn[.exe] not found, failing"
  exit 2
fi

all_tests(){
local post="$1"

test_set_cleanup "${SUDO} killall $OPENVPN"

trap 'test_bg_cleanup;exit' 0 2 15

STR_INIT_OK="Initialization Sequence Completed"

test_define "UDP6 loopback$post"
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp6-0-loopback.sh $O_ARGS

test_define "UDP6 loopback byname$post"
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp6-0-loopback-byname.sh $O_ARGS

test_define "UDP6 loopback4mapped$post"
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp6-0-loopback4mapped.sh $O_ARGS

test_define "UDP6 loopback4native$post"
test_bg_prev ${tdir?}/run-udp6-0-loopback_passive.sh
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp6-0-loopback4native.sh $O_ARGS

(set -x;${SUDO:-sudo} /sbin/ip -6 -o a </dev/tty >/dev/tty)
test_define "UDP6 loopback_multihome$post"
test_bg_prev ${tdir?}/run-udp6-0-loopback_listen_multihome.sh  $O_ARGS
test_bg_egrep 60 "Peer Connection Initiated with.*via" ${tdir?}/run-udp6-0-loopback_connect_multihome.sh $O_ARGS

if ping6 -c 1 "$REM6" >/dev/null 2>&1;then
  test_define "UDP6 remote$post"
  test_bg_prev ${tdir?}/run-udp6-1-rem.sh --ping-exit 60 $O_ARGS
  test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp6-1-loc.sh --ping-exit 60 $O_ARGS

  test_define "TCP6 remote$post"
  test_bg_prev ${tdir?}/run-tcp6-1-server.sh --ping-exit 60
  test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp6-1-client.sh --ping-exit 60 $O_ARGS
else
  notice "REM6=\"$REM6\" not reachable, skipping remote UDP6,TCP6 tests"
fi
test_define "TCP6 loopback$post"
test_bg_prev ${tdir?}/run-tcp6-0-loopback-server.sh $O_ARGS
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp6-0-loopback-client.sh $O_ARGS

test_define "TCP6 loopback byname$post"
test_bg_prev ${tdir?}/run-tcp6-0-loopback-server-byname.sh $O_ARGS
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp6-0-loopback-client-byname.sh $O_ARGS

test_define "TCP6 loopback client4mapped$post"
test_bg_prev ${tdir?}/run-tcp6-0-loopback-server.sh $O_ARGS
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp6-0-loopback-client4mapped.sh $O_ARGS

test_define "TCP6 loopback client4native$post"
test_bg_prev ${tdir?}/run-tcp6-0-loopback-server.sh $O_ARGS
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp6-0-loopback-client4native.sh $O_ARGS

test_define "UDP4 loopback$post"
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp4-0-loopback.sh $O_ARGS

test_define "UDP4 loopback_multihome$post"
test_bg_prev ${tdir?}/run-udp4-0-loopback_listen_multihome.sh  $O_ARGS
test_bg_egrep 30 "Peer Connection Initiated with.*via" ${tdir?}/run-udp4-0-loopback_connect_multihome.sh $O_ARGS

test_define "TCP4 loopback$post"
test_bg_prev ${tdir?}/run-tcp4-0-loopback-server.sh  $O_ARGS
test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp4-0-loopback-client.sh $O_ARGS

}

#export GDB="valgrind"
all_tests
export GDB="valgrind"
#all_tests .vg
