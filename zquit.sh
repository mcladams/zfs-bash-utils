#! /bin/bash
# safe zquit by stopping zed then changing all ds that canmount to noauto
systemctl stop zfs-zed.service
service zfs-zed stop
for pro in $(ps -Af | grep -e ' zed' -e '/sbin/zed' | awk '{ print $2 }'); do
    kill -9 $pro
done
# zfs zed definetely dead so changed wont be reflected in zfs-list.cache
canmount=$(zfs list -H -o name,canmount | grep -E -e '[[:space:]]on$' | awk '{ print $1 }')
for ea in $canmount; do
    zfs set canmount=noauto $ea
done
echo "No zfs datasets with canmount=on so safe to exit, reboot, poweroff"
