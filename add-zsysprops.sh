#! /bin/bash

lastim=$(date +%s)
rootsets=$(zfs list -H -o name | grep ROOT)
for rset in $rootsets; do
    zfs set com.ubuntu.zsys:last-used=$lastim $rset
    if grep -q 'var' <<< $rset; then
        zfs set com.ubuntu.zsys:bootfs=no $rset
    else
        zfs set com.ubuntu.zsys:bootfs=yes $rset
    fi
    case $rset in
        *jammy*)
            zfs set com.ubuntu.zsys:last-booted-kernel=vmlinuz-5.15.0-46-generic $rset
        ;;
        *kaisen*)
            zfs set com.ubuntu.zsys:last-booted-kernel=vmlinuz-5.18.0-4-amd64 $rset
        ;;
        *pve40*)
            zfs set com.ubuntu.zsys:last-booted-kernel=vmlinuz-5.13.19-2-pve $rset
        ;;
    esac
done

usersets=$(zfs list -H -o name | grep USERDATA)
for uset in $usersets; do
    zfs set com.ubuntu.zsys:last-used=$lastim $uset
    zfs set com.ubuntu.zsys:bootfs-datasets=$(sed 's/USERDATA/ROOT/' <<< $uset) $uset
done

bootsets=$(zfs list -H -o name | grep BOOT)
for bset in $bootsets; do
    zfs set com.ubuntu.zsys:last-used=$lastim $bset
done
