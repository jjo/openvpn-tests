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
if [ -f openvpn ];then
  cp -p $PWD/openvpn $t/openvpn-test || exit 1
  export OPENVPN="$t/openvpn-test"
elif [ -f openvpn.exe ];then
  cp -p $PWD/openvpn.exe $t/openvpn-test.exe || exit 1
  export OPENVPN="$t/openvpn-test.exe"
fi

all_tests(){
local post="$1"

test_set_cleanup "ps ax | awk '/[o]penvpn-test/ { print \$1 }'  | ${SUDO} xargs -r kill"

trap 'test_bg_cleanup;exit' 0 2 15

test_define "UDP6 loopback$post"
test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-udp6-0-loopback.sh $O_ARGS

test_define "UDP6 loopback byname$post"
test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-udp6-0-loopback-byname.sh $O_ARGS

if ping6 -c 1 "$REM6" >/dev/null 2>&1;then
  test_define "UDP6 remote$post"
  test_bg_prev ${tdir?}/run-udp6-1-rem.sh --ping-exit 60 $O_ARGS
  test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-udp6-1-loc.sh --ping-exit 60 $O_ARGS

  test_define "TCP6 remote$post"
  test_bg_prev ${tdir?}/run-tcp6-1-server.sh --ping-exit 60
  test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-tcp6-1-client.sh --ping-exit 60 $O_ARGS
else
  notice "REM6=\"$REM6\" not reachable, skipping remote UDP6,TCP6 tests"
fi
test_define "TCP6 loopback$post"
test_bg_prev ${tdir?}/run-tcp6-0-loopback-server.sh $O_ARGS
test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-tcp6-0-loopback-client.sh $O_ARGS

test_define "TCP6 loopback byname$post"
test_bg_prev ${tdir?}/run-tcp6-0-loopback-server-byname.sh $O_ARGS
test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-tcp6-0-loopback-client-byname.sh $O_ARGS

test_define "UDP4 loopback$post"
test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-udp4-0-loopback.sh $O_ARGS

test_define "TCP4 loopback$post"
test_bg_prev ${tdir?}/run-tcp4-0-loopback-server.sh  $O_ARGS
test_bg_egrep 30 "Initialization Sequence Completed" ${tdir?}/run-tcp4-0-loopback-client.sh $O_ARGS

}

#export GDB="valgrind"
all_tests
export GDB="valgrind"
#all_tests .vg
