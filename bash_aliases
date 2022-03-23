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

## mine for zfs etc
alias du1='du -cxhd1'
alias du5='du -cxhd1 --all -t50M'

alias zls='zfs list -o name,used,referenced,canmount,mounted,mountpoint'

function zlm() {
    zfs list -o name,used,referenced,canmount,mounted,mountpoint $@ | egrep -e ' on ' -e ' yes '
}

function zlz() {
    zfs get -o name,property,value $@ all | egrep -e 'com\.ubuntu\.zsys'
}

alias zm='mount -t zfs -o zfsutil'
alias zu='umount -t zfs -lf'

function zma() {
    if [ "$1" = "-R" ]; then
        shift 1
        rooty="$1"
        shift 1
    else
        rooty="/z"
    fi
    fss=$(zfs list -H -o name $@)
#    echo $rooty
#    echo $fss
    for fs in $fss; do
        derr=$rooty/$fs
#        maybe=$(cat /proc/self/mounts | egrep -e $derr)
        if [ ! "$(cat /proc/self/mounts | egrep -e $derr)" = "" ]; then
            continue
        fi
        if [ ! -d $derr ]; then
            mkdir -p $derr
        fi
        if [ "$(zfs list -H -o mountpoint $fs)" = "legacy" ]; then
            mount -t zfs $fs $derr
        else
            mount -t zfs -o zfsutil $fs $derr
        fi
        echo "Mounted $fs on $derr"
    done
}

function zua() {
    if [ "$1" = "-R" ]; then
        shift 1
        rooty="$1"
        shift 1
    else
        rooty="/z"
    fi
    fss=$(zfs list -H -o name $@ | tac)
    # reverses output so unmount in order
    for fs in $fss; do
        derr=$rooty/$fs
        while [ "$(cat /proc/self/mounts | egrep -e $derr)" ]; do
             umount -t zfs $fs $derr 2> /dev/null
             umount -lf $derr 2> /dev/null
        done
    rm -r $derr 2> /dev/null
    echo "Unmounted $fs and removed $derr"
    done
}
