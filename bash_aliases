#! /bin/bash

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
#
#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

alias upg='apt update && apt upgrade -y && apt autoremove -y && apt autoclean'

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

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#### apt
alias rdeps='apt-cache rdepends --no-recommends --no-suggests --no-enhances'
alias deps='apt-cache depends --no-recommends --no-suggests --no-enhances'
# versions with recommends; some metapackages use recommends
alias rdepr='apt-cache rdepends --no-suggests --no-enhances'
alias depr='apt-cache depends --no-suggests --no-enhances'

#### disk usage ####
alias du1='du -cxhd1'
alias du5='du -cxhd1 --all -t50M'

#### other aliases
alias lsb='lsblk -o name,size,fstype,label,mountpoint,kname,uuid'

#### general functions
# list user functions defined
# alternatively 'compgen -A function'
alias flist='declare -F |cut -d" " -f3 |egrep -v "^_"'
alias fdef='declare -f'

pname_abs() {
# pn_abs: get absolute pathname from relative
    abspn=$(readlink -f `pwd`/$1)
    filename=${abspn##*/}
    path=${abspn%/*}
    echo $abspn
    #echo $path $filename
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
    #usage rename default or overwrite origial with --overwrite -w 
    if ([ "$1" = "-w" ] || [ "$1" = "--overwrite" ]); then
        overwrite=true
        shift 1
    fi
    pkges="$@"
    for pkg in $pkges; do
        pname=$(echo "$pkg" | sed 's/\.deb//g')
        files=$(ar -t "$pname".deb)
        if grep -q "control.tar.xz" <<< $files; then
            : #echo archive already xz nothing to do
        else
            ar -x "$pname".deb
            zstd -d < control.tar.zst | xz > control.tar.xz
            zstd -d < data.tar.zst | xz > data.tar.xz
            if $overwrite; then
                rm "$pname".deb
                ar -m -c -a sdsd "$pname".deb debian-binary control.tar.xz data.tar.xz
            else
                ar -m -c -a sdsd "$pname"-xz.deb debian-binary control.tar.xz data.tar.xz
            fi
            rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst
        fi
    done
}

mnt() {
    mtpoint=$(eval echo '$'$#)
    if [ ! -d "$mtpoint" ]; then
        mkdir -p "$mtpoint"
        mount "$@"
        return
    else
        if grep -q "$mtpoint" <<< $(cat /self/proc/mounts); then
            devmounted=$(cat /proc/self/mounts | grep "$mtpoint" | awk '{ print $1 }')
            read -p "$devmounted is already mounted at $mntpoint" -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then mount "@"; return; fi
        else
            mount "$@"
        fi
    fi
}

mnta() {
    for arg in "$@"; do
        if grep -q "$arg" <<< $(lsblk -n -o label); then
            argnospace=$(echo "$arg" | sed 's/[ ]/\-/g')
            mkdir /media/mnt/$argnospace
            mount LABEL="$arg" /media/mnt/$argnospace
        elif grep -q ${arg##*/} <<< $(lsblk -n -o kname); then
            kdev=${arg##*/}
            mkdir /media/mnt/$kdev
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

#alias zm='mount -t zfs -o zfsutil'
alias zum='umount -t zfs -lf'

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
    zfs snapshot $fs@zmnt-$mp_`date -Iminutes | sed 's/+08:00//'`
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
        rooty="$2"
        shift 2
    else
        rooty="/z"
    fi
    fss=$(zfs list -H -o name "$@")
    for fs in $fss; do
        mpz=$rooty/$fs
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
    if [ "$1" = "-R" ]; then
        rooty="$2"
        shift 2
    else
        rooty="/z"
    fi
    fss=$(zfs list -H -o name $@ | tac)
    # reverses output so unmount in order
    for fs in $fss; do
        mpz=$rooty/$fs
        zum $fs $mpz
        if [ "$(cat /proc/self/mounts | egrep -e $mpz)" ]; then
             umount -lf $fs
        fi
        rm -r $mpz
    echo "Unmounted $fs and removed $mpz"
    done
    echo testing if fs remains $fs $mpz
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
