#!/bin/sh
# ex1-rename-net-dev.sh: Change the network interface name in systemd scripts
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
echo 'ex1-rename-net-dev Copyright 2013 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';

ND_OLD=$1;
shift;
ND_NEW=$1;


if [ 0 -ne $UID ]; then
    echo 'Please run as root';
    exit 1;
fi;


# Validate new network device
if [ -z $ND_OLD ]; then
    echo 'Current network interface name was not provided.';
    exit 1;
fi;

if [ -z $ND_NEW ]; then
    echo 'New network interface name was not provided.';
    exit 1;
fi;

if [ -z "`ip link show $ND_NEW 2>/dev/null|grep \": $ND_NEW:\"`" ]; then
    echo "Invalid network interface '$ND_NEW'";
    exit 1;
fi;

echo "Current network interface : $ND_OLD";
echo "New network interface     : $ND_NEW";
echo '';

read -n1 -s -p 'Press any key to continue';
echo '';
echo '';


# Start replacing device name
sed "s/$ND_OLD/$ND_NEW/g" -i /etc/systemd/system/dhcpcd\@.service;

mv /etc/systemd/system/multi-user.target.wants/dhcpcd\@{$ND_OLD,$ND_NEW}.service;

mv /etc/systemd/system/dhcpcd\@{$ND_OLD,$ND_NEW}.service.wants

mv /etc/systemd/system/dhcpcd\@$ND_NEW.service.wants/wpa_supplicant\@{$ND_OLD,$ND_NEW}.service;

mv /etc/wpa_supplicant/wpa_supplicant-{$ND_OLD,$ND_NEW}.conf;

mv /etc/systemd/system/var-cache-pacman-pkg.mount.wants/dhcpcd\@{$ND_OLD,$ND_NEW}.service
mv /etc/systemd/system/var-lib-pacman-sync.mount.wants/dhcpcd\@{$ND_OLD,$ND_NEW}.service
