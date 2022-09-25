#!/bin/bash
# get the titles of all menu-entries in grub menu
# get-grub-entrytitles.sh [-g path_to_grub_configfile] [-o outputfile]

if [ "$1" = "-g" ]; then
    configfile="$2"
    shift 2
else
    configfile="/boot/grub/grub.cfg"
fi

if [ "$1" = "-o" ]; then
    outfile="$2"
fi

grep -E -e '^[[:blank:]]*menuentry.*\{$' /boot/efi/grub/grub.cfg | \
  sed -E 's/^[[:blank:]]*menuentry ['"'"']//g' | sed -E 's/['"'"'].*menuentry_id_option.*\{$//g'

if [ "$outfile" ]; then
    echo "$menuentries_grub" > "$outfile"
else
    echo "$menuentries_grub"
fi
