#!/bin/bash
set -eux
ip link add dev wgExit type wireguard
ip address add dev wgExit 172.168.1.254
wg setconf wgExit /etc/wireguard/wgExit.conf
ip link set up dev wgExit
