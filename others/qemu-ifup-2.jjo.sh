#!/bin/sh -x
#sudo sh -c "/sbin/ifconfig $1 hw ether 00:00:00:00:00:01; /sbin/ifconfig $1 192.168.254.1"
export PATH=/sbin:/usr/sbin:$PATH
NUM=2
DEV=qemutun$NUM
sudo sh -x <<EOF
ip li set $1 name $DEV
ip li set $DEV address 00:00:00:00:00:01
ip li set $DEV up
ip ad add 192.168.254.1 dev $DEV
ip ro add 192.168.254.$NUM dev $DEV
EOF
