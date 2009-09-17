#!/bin/bash
# Crude but useful unittests for openvpn over ipv6/4
# Author: JuanJo Ciarlante
export LIBTEST_OUTPUT_DIR=/tmp

# my_env.sh should contain the following vars:
#   REM6="2002:5457:5de5:2:20d:b9ff:fe29:901a"
source ${0%/*}/my_env.sh || exit 1
source ${0%/*}/libtest.sh || exit 1

t=$LIBTEST_OUTPUT_DIR
cp -pu $PWD/openvpn $t/openvpn-test || exit 1
my_dir=${0%/*}
export OPENVPN="$t/openvpn-test"

all_tests() {
local post="$1"

test_set_cleanup "ps ax | awk '/[o]penvpn-test/ { print \$1 }'  | ${SUDO} xargs -r kill"

trap 'test_bg_cleanup;exit' 0 2 15

test_define "UDP6 loopback$post"
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-0-loopback.sh

test_define "UDP6 loopback byname$post"
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-0-loopback-byname.sh

if ping6 -c 1 "$REM6" >/dev/null 2>&1;then
  SUDO=sudo
  test_bg_cleanup ## special SUDO forces
  test_define "UDP6 remote$post"
  test_bg_prev ${my_dir?}/run-udp6-1-rem.sh --ping-exit 30
  test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-1-loc.sh --ping-exit 30

  test_bg_cleanup ## special SUDO forces
  sudo killall -q -9 openvpn-test
  test_define "TCP6 remote$post"
  test_bg_prev ${my_dir?}/run-tcp6-1-server.sh --ping-exit 30
  sleep 10
  test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp6-1-client.sh --ping-exit 30
  sudo killall -q -9 openvpn-test
  test_bg_cleanup ## special SUDO forces
  unset SUDO
else
  notice "REM6=\"$REM6\" not reachable, skipping remote UDP6,TCP6 tests"
fi
test_define "TCP6 loopback$post"
test_bg_prev ${my_dir?}/run-tcp6-0-loopback-server.sh
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp6-0-loopback-client.sh

test_define "TCP6 loopback byname$post"
test_bg_prev ${my_dir?}/run-tcp6-0-loopback-server-byname.sh
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp6-0-loopback-client-byname.sh

test_define "UDP4 loopback$post"
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp4-0-loopback.sh

test_define "TCP4 loopback$post"
test_bg_prev ${my_dir?}/run-tcp4-0-loopback-server.sh 
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp4-0-loopback-client.sh

}

#export GDB="valgrind"
all_tests
export GDB="valgrind"
#all_tests .vg
