#!/usr/bin/env bash
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
test_set_cleanup "pkill ${OPENVPN##*/};fuser -k $OPENVPN >/dev/null 2>&1"
trap 'test_bg_cleanup;exit' 0 2 15

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
test_report

}

#export GDB="valgrind"
all_tests
