#!/bin/bash -eux

# Upgrade the kernel to 4.9 so we get eBPF
echo deb http://http.debian.net/debian jessie-backports main > /etc/apt/sources.list.d/jessie-backports.list
apt-get -t jessie-backports install linux-latest-modules-4.9.0-0.bpo.2-amd64 linux-headers-4.9.0-0.bpo.2-amd64

# reboot
echo "Rebooting the machine..."
reboot
sleep 60
