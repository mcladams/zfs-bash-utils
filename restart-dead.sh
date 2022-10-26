#! /bin/sh
# restart-dead.sh - look for enabled systemd unit files that are inactive or active
# and either failed or dead and reload-or-restart them
######## useful after suspend e.g. zfz-zed.service running becore suspend dead aft>
######## but does not report failed

deadorfailed0=$(systemctl list-units --all $(systemctl list-unit-files --all | \
  grep enabled | awk '{ print $1 }') | egrep -e 'loaded[[:blank:]]+\w+[[:blank:]]+dead' \
  -e 'loaded[[:blank:]]+/w+[[:blank:]]+failed' | sed s/^..// | awk '{ print $1 }')

echo "Trying systemctl reload-or-restart on dead and failed units..."
for unit in $deadorfailed0; do
    systemctl reload-or-restart $unit 2>/dev/null
done
echo

dead=$(systemctl list-units --all $(systemctl list-unit-files --all | \
  grep enabled | awk '{ print $1 }') | egrep -e 'loaded[[:blank:]]+\w+[[:blank:]]+dead' \
  | sed s/^..// | awk '{ print $1 }')
failed=$(systemctl list-units --all $(systemctl list-unit-files --all | grep \
  enabled | awk '{ print $1 }') | egrep -e 'loaded[[:blank:]]+\w+[[:blank:]]+failed' \
  | sed s/^..// | awk '{ print $1 }')

echo "Successfully restarted units:"
printf "$deadorfailed0\n$dead\n$failed" | sort | uniq -u
echo

echo "Current (exported env variables) DEAD and FAILED units:"
systemctl list-units --all $(systemctl list-unit-files --all | \
  grep enabled | awk '{ print $1 }') | egrep -e 'loaded[[:blank:]]+\w+[[:blank:]]+dead' \
  -e 'loaded[[:blank:]]+/w+[[:blank:]]+failed' | sed s/^..//
echo "(...future options to get status, edit/view unit files)"
