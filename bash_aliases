#!/bin/bash

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
#
#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -Al'
alias la='ls -A'
alias l='ls -CF'

#### apt maintenance
alias upg='apt update && apt upgrade -y && apt autoremove -y && apt autoclean'
alias upgf='apt update && apt upgrade -y && apt full-upgrade -y && apt autoremove -y && apt autoclean'
alias apt-nir='apt install --no-install-recommends'
alias apt-arp='apt remove --autoremove --purge'
apt-lsi() { apt list $@ | egrep -e '\[.*\]'; }
apt-lsi1() { apt list $@ | egrep -e '\[.*\]'; egrep -e '^[^/]+' -o; }
apt-lsn() { apt list $@ | egrep -e '\[.*\]' -v; }
apt-lsn1() { apt list $@ | egrep -e '\[.*\]' -v; egrep -e '^[^/]+' -o; }

# search for packages with residual-config and purge
alias apt-rmconf='apt update; apt-get remove --autoremove --purge $(for l in {a..z}; do apt list $l* 2>/dev/null | grep -E -e "\[residual\-config\]" | grep -E -e "^[^/]+" -o; done)'

####TODO display all reverse depends of all manually installed pkgs
#finalrdeps() {
#    maninstalls=$(apt-mark showmanual | sort | uniq)
#    for pkg in $maninstalls; do
#        uniqs=$(apt-cache rdepends --no-recommends --no-suggests --no-enhances $pkg | egrep -e '^[ ][ |]' | sed 's/[ ][ |]//g' | sort | uniq)
#        if [ -z $uniqs ]; then echo $pkg >> nordeps.list; fi
#        dpkg-query -l $uniqs | egrep -e '^ii' | awk '{ print $2 }' >> allrdeps.list
#    done
#}

#### apt
alias rdeps='apt-cache rdepends --no-recommends --no-suggests --no-enhances --no-breaks --no-replaces'
alias deps='apt-cache depends --no-recommends --no-suggests --no-enhances --no-breaks --no-replaces'
# versions with recommends; some metapackages use recommends
alias rdepr='apt-cache rdepends --no-suggests --no-enhances --no-breaks --no-replaces'
alias depr='apt-cache depends --no-suggests --no-enhances --no-breaks --no-replaces'

wol() {
    #definition of MAC addresses
    pve10_tower="50:e5:49:e9:04:66"
    pve20_arrow="e0:69:95:3b:c4:3e"
    pve30_a515="98:28:a6:1a:90:7a"
    pve40_pb470="dc:4a:3e:f0:1e:af"
    pve50_gamer="d8:50:e6:57:a3:51"

    echo "Which PC to wake?"
    echo "  1) pve10-tower    $pve10_tower    192.168.20.10"
    echo "  2) pve20-arrow    $pve20_arrow    192.168.20.20"
    echo "  3) pve30-a515     $pve30_a515     192.168.20.30"
    echo "  4) pve40-pb470    $pve40_pb470    192.168.20.40"
    echo "  5) pve50-gamer    $pve50_gamer    192.168.20.50"
    echo "  6) oldpro"
    echo "  7) dellbox"
    read -n1 input1
    case $input1 in
        (1) /usr/bin/wakeonlan $pve10_tower ;;
        (2) /usr/bin/wakeonlan $pve20_arrow ;;
        (3) /usr/bin/wakeonlan $pve30_a515 ;;
        (4) /usr/bin/wakeonlan $pve40_pb470 ;;
        (5) /usr/bin/wakeonlan $pve50_gamer ;;
        (Q|q) break ;;
    esac
}


####TODO restart all enabled dead units (useful after awakint)
#for unit in $(systemctl list-units $(systemctl list-unit-files --state=enabled | awk "{ print $1 }") \
# | grep -e dead -e failed | awk "{ print $1 }" ) ; do systemctl restart $unit; done

#### disk usage ####
alias du1='du -cxhd1'
alias du5='du -cxhd1 --all -t20M'

#### other aliases
alias lsb='lsblk -o name,size,type,partlabel,fstype,label,mountpoint'
alias lsbu='lsblk -o name,size,fstype,label,uuid,mountpoint'
alias lsbp='lsblk -o name,size,fstype,label,partuuid,mountpoint'
alias lsbup='lsblk -o name,size,fstype,label,uuid,kname,type,partuuid'

#### general functions
# list user functions defined
# alternatively 'compgen -A function'
alias flist='declare -F |cut -d" " -f3 | egrep -v "^_"'
alias fdef='declare -f'

lsiommu() {
# lsiommu: list members of iommu groups
    shopt -s nullglob
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        echo "IOMMU Group ${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ${d##*/})"
        done;
    done;
    shopt -u nullglob
}

pname_abs() {
# pn_abs: get absolute pathname(s) from relative
    if [ ! -a $1 ]; then
        echo '"'$1'"' was not found.
        return
    fi
    pathname=$(readlink -f $1)
    filename=${pathname##*/}
    path=${pathname%/*}
    #echo $path $filename $pathname
    echo $pathname
}

#### rsync ####

rs_cp() {
# copy-overwrite dest if different regardless
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX "$@"
}

rs_up() {
# copy-update do not overwrite newer on dest
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX --update "$@"
}

rs_cl() {
# copy-clone by removing extra dest files
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX --delete "$@"
}

rs_mv() {
# move by removing source files
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX --remove-source-files "$@"
}

#rs_sys { #full system filesystem backup
#
#

#### apt,dpkg,etc ####
deb2xz() {
    set -e
    pkges="$@"
    for pkg in $pkges; do
        if [ ! "${pkg##*.}" = "deb" ] || [ ! -f $pkg ]; then
            echo '"'$pkg'"' is not a file or does not end in .deb
            continue
        elif grep -q "control.tar.xz" <<< $files; then
            echo '"'$pkg'"' is already in tar.xz format, not touching it.
            continue
        fi
        pathname=$(readlink -f $pkg)
        path=${pathname%/*}
        filename=${pathname##*/}
        pkgname=${filename%.*}
        # do it in a tmp dir
        mkdir /tmp/$pkgname
        pushd /tmp/$pkgname
        ar -x $pathname
        zstd -d < control.tar.zst | xz > control.tar.xz
        zstd -d < data.tar.zst | xz > data.tar.xz
        mv $pathname /tmp/$filename
        ar -m -c -a sdsd $pathname debian-binary control.tar.xz data.tar.xz
        popd
    done
    echo "Done. Original debs move to /tmp"
}

mnt() {
    mtpoint=$(eval echo '$'$#)
#    realmp=$(realpath -m $mtpoint)
    if [ ! -a $mtpoint ]; then
        mkdir -p $mtpoint
        mount "$@"
        return
    elif [ ! -d "$mtpoint" ]; then
        echo "Mointpoint is not a directory, not mounting $@"
        return 1
    else
#        if grep -q " $realmp" <<< $(cat /proc/self/mounts); then
#            mtdevs=$(cat /proc/self/mounts | grep " $realmp" | awk '{ print $1 }')
#            echo -n "$mtdevs already mounted at $realmp, overlay? :"
#            read -n1 input1
#            echo
#            if [[ $input1 =~ ^[Yy]$ ]]; then
#                mount "$@"
#                return
#            else
#                echo "Did not mount $@"
#                return 1
#            fi
#        elif [ "$(ls -A1 $mtpoint)" ]; then
#            read -p "Directory $mtpoint is not empty, overlay? :" -n1 input2
#            echo
#            if [[ $input2 =~ ^[Yy]$ ]]; then
#                mount "$@"
#                return
#            else
#                echo "Did not mount $@"
#                return
#            fi
#        else
            mount "$@"
#        fi
    fi
}

mnta() {
    for arg in $@; do
        if grep -q "$arg" <<< $(lsblk -n -o label); then
            #argnospace=$(echo "$arg" | sed 's/[ ]/\-/g')
            mkdir -p /media/mnt/$argnospace
            mount LABEL="$arg" /media/mnt/$argnospace
        elif grep -q ${arg##*/} <<< $(lsblk -n -o kname); then
            kdev=${arg##*/}
            mkdir -p /media/mnt/$kdev
            mount /dev/$kdev /media/mnt/$kdev
        else
            echo "$arg" neither a label nor a device name, not mounted
        fi
    done
}

#### zfs list,mount,move ####

alias zls='zfs list -o name,used,referenced,canmount,mounted,mountpoint'

zlsm() {
# zfs list mount - list datasets with canmount=on and/or currently mounted
    zfs list -o name,used,referenced,canmount,mounted,mountpoint $@ | egrep -e ' on ' -e ' yes '
}

zlsz() {
# zfs list zsys - show zsys custom properties of datasets (fs,snap,all)
    if [ "$1" = "-t" ]; then
        type="$2"
        shift 2
    else
        type="filesystem"
    fi
    if [ "$1" = "-r" ]; then
        recurs="-r"
        shift 1
    fi
    zfs get $recurs -o name,property,value -t $type all "$@" | egrep -e 'com\.ubuntu\.zsys'
}

#### zfs list/get properties from name
alias zg_t='zfs list -H -o type'
alias zg_mt='zfs list -H -o mounted'
alias zg_mp='zfs list -H -o mountpoint'
alias zg_cm='zfs list -H -o canmount'

alias zm='mount -t zfs -o zfsutil'
alias zu='umount -t zfs'

zmt() {
    fs=$1
    mp=$2
    if [ ! -d "$mp" ]; then
        mkdir -p $mp
    elif [ "$(cat /proc/self/mounts | grep $mp )" ]; then
        echo "Error: another device or filesystem is already mounted on $mp"
        return
    elif [ ! "$(find $mp -maxdepth 0 -empty)" ]; then
        echo "Error: $mp exists and is not empty, not mounting"
        return
    fi
    if [ "$(zg_cm $fs)" = "off" ]; then
        echo "Note $fs has canmount=off so not mounted represented by empty directory $mp"
        return
    fi
#    zfs snapshot $fs@zmnt-$mp_`date -Iminutes | sed 's/+08:00//'`
    if [ "$(zg_t $fs)" = "snapshot" ] || [ "$(zg_mp $fs)" = "legacy" ]; then
        mount -t zfs $fs $mp
    else
        mount -o zfsutil -t zfs $fs $mp
    fi
    echo mounted $fs on $mp
}

# mount -t zfs [-o zfsutil] datasets [recursively] to their name under a root directory
zma() {
    if [ "$1" = "-R" ]; then
        local rooty="$2"
        shift 2
#    else
#        rooty="/z"
    fi
    fss=$(zfs list -H -o name "$@")
    for fs in $fss; do
        if [ $rooty ]; then
            mpz=$rooty$(zg_mp $fs)
        else
            mpz=$rooty/$fs
        fi
        if [ ! "$(cat /proc/self/mounts | egrep -e $mpz)" = "" ]; then
            echo "Mount point $mpz used, not mounting $fs"
            continue
        fi
        if [ ! -d $mpz ]; then
            mkdir -p $mpz
        fi
        # new - mounting of canmount=off spacer datasets creates big trouble
        if [ "$(zfs list -H -o canmount $fs)" = "off" ]; then
            echo "Not mounting $fs with canmount=off but $mpz created if not exist"
            continue
        fi
        if [ "$(zfs list -H -o mountpoint $fs)" = "legacy" ]; then
            mount -t zfs $fs $mpz
        else
            mount -t zfs -o zfsutil $fs $mpz
        fi
        echo "Mounted $fs on $mpz"
    done
}

# umount -t zfs datasets [recursively] with force and remove mountpoints
zua() {
    fss=$(zfs list -H -o name $@ | tac)
    # reverses output so unmount in order
    for fs in $fss; do
        mpz=$(zfs list -H -o mountpoint $fs)
        umount -t zfs $fs 2>/dev/null
        umount $mpz 2>/dev/null
        umount -lf $mpz
        if [ $(zfs mount | grep "$fss " -o) ]; then
            echo "Error: $fs did NOT unmount from $mpz"
        elif [ "$(ls -A1 $mpz)" ]; then
            echo "Unmounted $fs; $mpz not empty so not removed"
        else
            rm -r $mpz
            echo "Unmounted $fs and removed $mpz"
        fi
    done
}

# mount ubuntu zfs / zsys datasets style
zmaz() {
# zfsutil mount rpool/ROOT/foo recurs, and USERDATA/foo BOOT/foo
    if [ "$1" = "-R" ]; then
        altr="$2"
        shift 2
    else
        altr="/z"
    fi
    dist="$1"
    zroot=rpool/ROOT/$dist
    eval zma -R $altr -r rpool/ROOT/$dist
    eval zmt bpool/BOOT/$dist $altr/$zroot/boot
    eval zmt rpool/USERDATA/$dist $altr/$zroot/home
}

#### take a manual zfs snap of mounted datasets
zsnap() {
    dstamp=$(date -Iminutes | sed 's/+08:00//')
    if [ "$1" ]; then
        nom="$1-$dstamp"
    else
        nom="manual-$dstamp"
    fi
    dss=$(zfs mount | awk '{ print $1 }')
    for ds in $dss; do
        zfs snapshot $ds@$nom
    done
}

#### repace spaces with underscore ####
underscore() {
#    if [ $1 ]; then maxd=$1; else maxd=20; fi
    for i in {1..18}; do
        find ./ -mindepth $i -maxdepth $i -regex '.*[ ].*' -print0 | xargs -0 sed 's/[ ]/_/g'
    done
}

# deb http://au.archive.ubuntu.com/ubuntu/ kinetic main universe
# deb http://security.ubuntu.com/ubuntu kinetic-security main universe

# apt install --no-install-recommends ubuntu-desktop ubuntu-standard \
# ubuntu-desktop-minimal ubuntu-minimal baobab branding-ubuntu deja-dup ]
# gnome-calendar shotwell simple-scan totem transmission-gtk usb-creator-gtk 
# gnome-disk-utility gparted gnome-shell gnome-control-center systemd \
# systemd-sysv systemd-oomd systemd-container zfsutils-linux zfs-zed \
# grub-efi-amd64 grub-pc-bin

alias zsnap_large='zfs list -o used,name -t snapshot | sort -h | tail' 
