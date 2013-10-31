#!/bin/sh
# 020-install-packages.sh: Setup pacman configuration and install base system.
#
#   Copyright 2013 Sudaraka Wijesinghe <sudaraka.org/contact>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


echo '';
echo '020-install-packages Copyright 2013 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';

echo 'IMPORTANT: Make sure you have the following pacman directories mounted.';
echo '  /var/cache/pacman/pkg';
echo '  /var/lib/pacman/sync';
read -n1 -s -p 'Press any key to continue';
echo '';
echo '';

echo 'Creating pacman configuration...';

# Make pacman ignore packages depended on Mono and Java
sed 's/#\(IgnorePkg\s*=\)/\1 mono mono-tools jre7-openjdk-headless/' \
    /etc/pacman.conf > /mnt/etc/pacman.conf 2>/dev/null;

# Add archlinux.fr repository for Yaourt
cat >> /mnt/etc/pacman.conf << EOF

[archlinuxfr]
Server = http://repo.archlinux.fr/\$arch
SigLevel = Optional
EOF

# Install base system
pacman -Sy --quiet -r /mnt --config /mnt/etc/pacman.conf \
    --ignore jfsutils,reiserfsprogs,xfsprogs,vi,nano,lvm2,netctl,linux,linux-firmware,heirloom-mailx,mdadm,pcmciautils\
    base base-devel syslinux wireless_tools wpa_supplicant gvim sudo yaourt \
    rsync wget git nfs-utils ntp bc haveged

echo '';

# Restore original pacman configuration file
echo 'Restoring pacman configuration file...';
mv /mnt/etc/pacman.conf{,.pacnew} >/dev/null 2>&1
mv /mnt/etc/pacman.conf{.pacorig,} >/dev/null 2>&1

# copy resolv.conf to new system
cp {,/mnt}/etc/resolv.conf >/dev/null 2>&1;

echo '';
