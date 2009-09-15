#!/bin/bash
source ${0%/*}/libtest.sh || exit 1

cp -pu $PWD/openvpn $t/openvpn-test
my_dir=${0%/*}
export OPENVPN="$t/openvpn-test"

all_tests() {

#test_set_cleanup "${SUDO} fuser -k ${OPENVPN}"
test_set_cleanup "ps ax | awk '/[o]penvpn-test/ { print \$1 }'  | ${SUDO} xargs -r kill"

trap 'test_bg_cleanup;exit' 0 2 15

test_define "UDP6 loopback"
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-0-loopback-self.sh

test_define "UDP6 loopback byname"
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-0-loopback-byname.sh

if fping jjolix;then
  DEV="$(/sbin/ip r get 1 | sed -r -n 's/.* dev ([^ ]+).*/\1/p')"
  export REM6="fe80::20d:b9ff:fe14:e09c%$DEV"
else
  export REM6=2002:5449:2ce5:2:20d:b9ff:fe14:e09c
fi
if ping6 -c 1 $REM6 >/dev/null 2>&1;then
  SUDO=sudo
  test_bg_cleanup ## special SUDO forces
  test_define "UDP6 remote"
  test_bg_prev ${my_dir?}/run-udp6-1-jjolix.sh --ping-exit 30
  test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-1-jjobuk.sh --ping-exit 30

  test_bg_cleanup ## special SUDO forces
  sudo killall -q -9 openvpn-test
  test_define "TCP6 remote"
  test_bg_prev ${my_dir?}/run-tcp6-1-jjolix-server.sh --ping-exit 30
  sleep 10
  test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp6-1-jjobuk-client.sh --ping-exit 30
  sudo killall -q -9 openvpn-test
  test_bg_cleanup ## special SUDO forces
  unset SUDO
else
  notice "REM6=$REM6 not reachable, skipping remote UDP6,TCP6 tests"
fi
test_define "TCP6 loopback"
test_bg_prev ${my_dir?}/run-tcp6-0-loopback-server.sh
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp6-0-loopback-client.sh

test_define "TCP6 loopback byname"
test_bg_prev ${my_dir?}/run-tcp6-0-loopback-server-byname.sh
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp6-0-loopback-client-byname.sh

test_define "UDP4 loopback"
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp4-0-loopback-self.sh

test_define "TCP4 loopback"
test_bg_prev ${my_dir?}/run-tcp4-0-loopback-server.sh 
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-tcp4-0-loopback-client.sh

}

#export GDB="valgrind"
all_tests
