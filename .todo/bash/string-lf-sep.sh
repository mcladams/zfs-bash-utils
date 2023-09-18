#!/usr/bin/env bash

#(return 0 2>/dev/null) && sourced=yes || sourced=""

lstfmt() {
#  Takes any string(s) and returns words deparated with CR
#  KISS no need to complicate with files
#  if [ -f "$1" ]; then files=yes; fi
  str="$@"
  str="${str//$'\n'/ }"
  strf=$(sed -E -e 's/^[[:space:]]+//g' -e 's/[[:space:]]+/ /g' -e 's/[[:space:]]+$//g' -e 's/ /\n/g' <<<$str)
  echo "$strf"
} 

#if [ ! $sourced ]; then stuff; fi
