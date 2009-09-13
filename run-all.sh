#!/bin/bash
source ${0%/*}/libtest.sh || exit 1

ln -sf $PWD/openvpn $t/openvpn-test
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
SUDO=sudo
test_bg_cleanup ## force
test_define "UDP6 remote"
test_bg_prev ${my_dir?}/run-udp6-1-jjolix.sh --inactive 30
test_bg_egrep 30 "Initialization Sequence Completed" ${my_dir?}/run-udp6-1-jjobuk.sh --inactive 30
unset SUDO
else
say "UDP6 remote declined (you're not @home)"
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
