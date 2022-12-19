#!/bin/bash
# event-znap: create autosnapshot in sanoid format "@autosnap_YYYY-MM-DD_hh:mm:ss_hourly" on,pre or post event
#
# default: snapshot root recursevily, record userproperty localhost:snap-event=$PARENT_DIR

# path=$(readlink -f `pwd`)  -only provides working path script was called from
scriptpath=$(dirname "$(readlink -f "$0")")
parent=${scriptpath##/*/}
zfs snapshot -r -o localhost:zsnap-event=$parent $(zfs list -o name,mounted,mountpoint | \
  egrep -e ' yes\s+\/$' | awk '{ print $1 }')@`date +autosnapshot_%F_%T_hourly`

