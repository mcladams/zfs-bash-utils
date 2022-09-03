#! /bin/bash

for arg in $@; do
    id=${arg##*/}
    rootds=$(zfs list | egrep -e '$id.*\/' | awk '{ print $1 }')
    if [ -z $rootds ]; then continue; fi
    lastim=$(date +%s)
    for ds in $(zfs list -H -o name | grep $id); do
        if ! zfs get all $ds | grep -q com.ubuntu.zsys:last=used; then
            zfs set org.ubuntu.zsys:last-used=$lastim $ds
        fi
        if [ "$(zfs list -H -o mountpoint $ds)" = "/boot" ]; then
            bootds=$ds
            mkdir /tmp/$ds
            mount -t zfs -o zfsutil -o readonly $ds /tmp/$ds
            bootkern=$(ls -1 --sort time /tmp/$ds | grep vmlinuz | head -n 1)
            umount -lf /tmp/$ds
        elif "$(zfs list -H -o mountpoint)" | grep -q -e 'home' -e 'root'; then
            userds+=("$ds")
        fi
    done
    if [ -z $bootkern ]; then
        mkdir /tmp/$id
        zfsmount -t zfs -o zfsutil -o readonly $bootds /tmp/$id
        kernver=$(ls -1 /tmp/$id/usr/lib/modules | tail -n 1)
        umount -lf /tmp/$id
        bootkern=$(eval echo 'vmlinuz-'$kernver)
        if [$ -z $bootkern ]; then $bootkern=vmlinuz; fi
    fi
    for rds in $(zfs list -H -o name -r $rootds); do
        if ! zfs get all $rds | grep -q com.ubuntu.zsys:bootfs; then
            zfs set org.ubuntu.zsys:bootfs=no $rds
        fi
        if ! zfs get all $rds | grep -q com.ubuntu.zsys:last-booted-kernel; then
            zfs set org.ubuntu.zsys:last-booted-kernel=$bootkern $rds
        fi
    done
    for uds in ${userds[@]}; do
        if ! zfs get all $uds | grep -q com.ubuntu.zsys:bootfs-datasets; then
            zfs set org.ubuntu.zsys:bootfsdatasets=$bootds $uds
        fi
    done
done
