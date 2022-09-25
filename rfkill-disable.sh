#! /bin/sh
mount --rbind /dev/null /etc/xdg/autostart/org.gnome.SettingsDaemon.Rfkill.desktop
mount --rbind /dev/null /usr/libexec/gsd-rfkill
mount --rbind /dev/null /usr/lib/systemd/systemd-rfkill
