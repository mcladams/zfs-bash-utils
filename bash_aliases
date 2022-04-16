#! /bin/sh

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
alias ll='ls -AlF'
alias la='ls -A'
alias l='ls -CF'

#### not sure origin of alert
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
#alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#### apt
alias rdeps='apt-cache rdepends --no-recommends --no-suggests --no-enhances'
alias deps='apt-cache depends --no-recommends --no-suggests --no-enhances'
# versions with recommends; some metapackages use recommends
alias rdepr='apt-cache rdepends --no-suggests --no-enhances'
alias depr='apt-cache depends --no-suggests --no-enhances'


#### disk usage ####
alias du1='du -cxhd1'
alias du5='du -cxhd1 --all -t50M'

#### rsync ####

rs_cp() { #copy-overwrite dest if different regardless
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX "$@"
}

rs_up() { #copy-update do not overwrite newer on dest
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX --update "$@"
}

rs_cl() { #copy-clone by removing extra dest files
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX --delete "$@"
}

rs_mv { #move by removing source files
    rsync -hh --info=stats1,progress2 --modify-window=2 -aHAX --remove-source-files "$@"
}

#rs_sys { #full system filesystem backup
#
#

#### zfs list,mount,move ####

alias zls='zfs list -o name,used,referenced,canmount,mounted,mountpoint'

zlm() {
    zfs list -o name,used,referenced,canmount,mounted,mountpoint $@ | egrep -e ' on ' -e ' yes '
}

zlz() {
    zfs get -o name,property,value $@ all | egrep -e 'com\.ubuntu\.zsys'
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
    elif [ "$(cat /proc/self/mounts | grep " $mp ")" ]; then
        echo "Error: $(cat /proc/self/mounts | grep ' $mp ' | awk '{ print $1 }') is mounted on $mp"
        return
    elif [ ! "$(find $mp -maxdepth 0 -empty)" ]; then
        echo "Error: $mp exists and is not empty, not mounting"
        return
    fi
    if [ $(zfs list -H -o canmount $fs) = off ]; then
        echo "Note $fs has canmount=off so not mounted represented by empty directory $mp"
        return
    fi
#    if [ "zfs list -H -o name
    mount -o zfsutil -t zfs $fs $mp
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
            echo "Mount point $mpz used, not mounting $fs (already mounted?)"
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
        if
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
        if [ "$(cat /proc/self/mounts | egrep -e $mpz)" ]; do
             umount -f -t zfs $fs 2> /dev/null
             umount -lf -t zfs $fs $mpz 2> /dev/null
             umount -lf $mpz 2> /dev/null
        done
    rm -r $mpz 2> /dev/null
    echo "Unmounted $fs and removed $mpz"
    done
}

# mount ubuntu zfs / zsys datasets style
zmaz() {
    if [ "$1" = "-R" ]; then
        altr="$2"
        shift 2
    else
        altr="/z"
    fi
    zdist=$1
    zroot=rpool/ROOT/$1


#### take a manual zfs snap of mounted datasets
zsnap() {
    dstamp=$(date +%Y%m%d.%H%M)
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
#    if [ "$1" ]; then maxd="$1"; else maxd=20; fi
    for i in {1..18}; do
        find ./ -mindepth $i -maxdepth $i -path "* *" -print0 | xargs -0 rename 'y/ /_/'
    done
}
