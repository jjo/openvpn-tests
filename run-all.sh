#!/bin/bash
# Crude but useful unittests for openvpn over ipv6/4
# Author: JuanJo Ciarlante
export LIBTEST_OUTPUT_DIR=~/tmp

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

test_set_cleanup "pkill ${OPENVPN##*/};fuser -k $OPENVPN >/dev/null 2>&1"

trap 'test_bg_cleanup;exit' 0 2 15

STR_INIT_OK="Initialization Sequence Completed"

test_cleanup
for t in \
	trun-remote.sh \
	trun-tcp-loopback.sh \
	trun-inetd.sh \
	trun-udp-loopback.sh \
	;do
	plan="$(${tdir?}/$t plan)"
	eval "$plan"
done


if _ping6 -c 1 "$REM6" >/dev/null 2>&1;then
  test_define "UDP6 remote$post"
  test_bg_prev ${tdir?}/run-udp6-1-rem.sh --ping-exit 60 $O_ARGS
  test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-udp6-1-loc.sh --ping-exit 60 $O_ARGS

  test_define "TCP6 remote$post"
  test_bg_prev ${tdir?}/run-tcp6-1-server.sh --ping-exit 60
  test_bg_egrep 30 "$STR_INIT_OK" ${tdir?}/run-tcp6-1-client.sh --ping-exit 60 $O_ARGS
else
  notice "REM6=\"$REM6\" not reachable, skipping remote UDP6,TCP6 tests"
fi

test_report

}

#export GDB="valgrind"
all_tests
export GDB="valgrind"
#all_tests .vg
