#! /bin/bash

ethifs=$(ip -br link | egrep -e '^e' | awk '{ print $1 }')
for enp in $ethifs; do
    enpmac=$(ip -br link | grep \^$enp | awk '{ print $3 }')
    if [ "$(ethtool $enp | egrep -e '^[[:space:]]*Wake-on' | awk '{ print $2 }' )" = "g" ]; then
        echo "Wake-on magic-packet (g) already activated for $enp at $enpmac"
        continue
    fi
    wolsup=$(ethtool $enp | grep -e 'Supports Wake-on' | awk '{ print $3 }' )
    if [[ $wolsup = *g* ]]; then
        ethtool -s $enp wol g
        printf "[Match]\nMACAddress=$enpmac\n\n[Link]\nNamePolicy=kernel database \
onboard slot path\nMACAddressPolicy=persistent\nWakeOnLan=magic"\n} \
>> /etc/systemd/network/50-wired.link
        echo "WOL-g activated and added to /etc/systemd/network/50-wired.link"
    else
        echo "Interface $enp at $enpmac does not support wake-on-lan"
    fi
done
