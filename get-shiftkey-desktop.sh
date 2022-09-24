#! /bin/bash
# source: https://github.com/shiftkey/desktop

# install gpg certificate
wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null

# if you want to use the US mirror
echo "deb [arch=amd64] https://mirror.mwt.me/ghd/deb/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list

# Then install GitHub Desktop:
apt update && apt install github-desktop
