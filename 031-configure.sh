#!/bin/sh
# 031-configure.sh: Configure the new system in chroot before booting into it.
#
#   Copyright 2013, 2014 Sudaraka Wijesinghe <sudaraka.org/contact>
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
echo '031-configure Copyright 2013, 2014 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';

HOSTNAME=$1;
shift
USER=$1
shift
RFKILL=$1

LAN_SERVER=`grep 'nameserver' /etc/resolv.conf|cut -d' ' -f2`;
WL_DEV=`ip link|grep ': wl'|cut -d':' -f2|tr -d ' '|head -n1`;
SWAP_PARTITION=`swapon -s|sed -n 2p|cut -d' ' -f1`;
HOME_PARTITION=`mount|grep 'on /home'|cut -d' ' -f1`;
DSK2_PARTITION=`mount|grep 'on /disk2'|cut -d' ' -f1`;

if [ -z "$EN_DEV" ]; then
    EN_DEV=`ip link|grep ': en\|eth'|cut -d':' -f2|tr -d ' '|head -n1`;
fi;

if [ -z "$WL_DEV" ]; then
    NET_DEV=$EN_DEV;
else
    NET_DEV=$WL_DEV;
fi;

echo "Hostname          : $HOSTNAME";
echo "Server IP         : $LAN_SERVER";
echo "Network interface : $NET_DEV";
echo "Username          : $USER";
echo "Swap File         : $SWAP_PARTITION";
echo "Home Partition    : $HOME_PARTITION";
echo -n 'Extra Partition   : ';
if [ -z "$DSK2_PARTITION" ]; then
    echo 'n/a';
else
    echo $DSK2_PARTITION;
fi;
echo -n 'Enable Rfkill     : ';
if [ -z "$RFKILL" ]; then
    echo 'No';
else
    echo 'Yes';
fi;
echo '';

read -n1 -s -p 'Press any key to continue';
echo '';
echo '';

# Create fstab
echo 'Creating /etc/fstab...';

cat >> /etc/fstab << EOF

/dev/sda1 / ext4 defaults,noatime,nodiratime,discard,errors=remount-ro 0 1
$HOME_PARTITION /home ext4 defaults,noatime,nodiratime,discard,errors=remount-ro 0 1
$SWAP_PARTITION none swap defaults,noatime,nodiratime 0 0
EOF

# Mount disk2
if [ ! -z $DSK2_PARTITION ]; then
    cat >> /etc/fstab << EOF

$DSK2_PARTITION /disk2 ext4 noauto,x-systemd.automount,defaults,noatime,nodiratime,errors=remount-ro 0 2
EOF
fi;

# Mount pacman cache on NFS
cat >> /etc/fstab << EOF

$LAN_SERVER:/home/pacman/cache/`uname -m` /var/cache/pacman/pkg nfs noauto,x-systemd.automount,noexec,nolock,noatime,nodiratime,rsize=32768,wsize=32768,timeo=14,intr,nfsvers=3 0 0
$LAN_SERVER:/home/pacman/sync/`uname -m` /var/lib/pacman/sync nfs noauto,x-systemd.automount,noexec,nolock,noatime,nodiratime,rsize=32768,wsize=32768,timeo=14,intr,nfsvers=3 0 0
EOF

# Hostname
echo 'Set hostname...';
echo $HOSTNAME > /etc/hostname;
sed "s/\(localhost\)$/\1 $HOSTNAME/g" -i /etc/hosts;

# Timezone and system time
echo 'Asia/Colombo' > /etc/timezone;
ln -s /usr/share/zoneinfo/Asia/Colombo /etc/localtime;
hwclock --hctosys --utc;

# NTP setup
ln -s /usr/lib/systemd/system/ntpd.service \
    /etc/systemd/system/multi-user.target.wants/;
sed 's/\(server\s\+.\+\)/#\1/' -i /etc/ntp.conf;
echo "server $LAN_SERVER" >> /etc/ntp.conf;

# Generate locale
echo 'Generating locale...';
cat >> /etc/locale.gen << EOF

en_US UTF-8
si_LK UTF-8
EOF

locale-gen >/dev/null 2>&1;

cat >> /etc/locale.conf << EOF

LANG=en_US
EOF

# Systemd adjustments
echo 'Configuring systemd...';

# Stop console clearing at login prompt
sed 's/\(TTYVTDisallocate=\)yes/\1no/' \
    /usr/lib/systemd/system/getty\@.service \
    > /etc/systemd/system/getty\@.service;
rm /etc/systemd/system/getty.target.wants/getty\@tty1.service >/dev/null 2>&1;
ln -s ../getty\@.service \
    /etc/systemd/system/getty.target.wants/getty\@tty1.service;

# Limit number of TTYs
sed 's/#\(NAutoVTs=\).\+/\12/' -i /etc/systemd/logind.conf >/dev/null 2>&1;

# Limit journal disk usage
sed 's/#\(SystemMaxUse=\).*/\116M/' -i /etc/systemd/journald.conf \
    >/dev/null 2>&1;

# Make network connection on boot
systemctl enable systemd-networkd
systemctl enable systemd-resolved

cat > /etc/systemd/network/lan.network << EOF
[Match]
Name=wlp*
#Name=enp*

[Network]
DHCP=yes
EOF

rm /etc/resolv.conf >/dev/null 2>&1;
ln -s /run/systemd/resolve/resolv.conf /etc/ >/dev/null 2>&1;

# Wireless network specific settings
if [ "$WL_DEV" == "$NET_DEV" ]; then
    systemctl enable wpa_supplicant@wlp2s0

    ln -s wifi.conf /etc/wpa_supplicant/wpa_supplicant-$NET_DEV.conf \
        >/dev/null 2>&1;

    if [ ! -z "$RFKILL" ]; then
        mkdir -p /etc/systemd/system/wpa_supplicant\@$NET_DEV.service.wants \
            >/dev/null 2>&1;

        ln -s /usr/lib/systemd/system/rfkill-unblock\@.service \
            /etc/systemd/system/wpa_supplicant\@$NET_DEV.service.wants/rfkill-unblock\@wifi.service >/dev/null 2>&1;
    fi;
fi;

# Make default systemd target multi-user to avoid missing login manager warning
ln -s /usr/lib/systemd/system/multi-user.target \
    /etc/systemd/system/default.target >/dev/null 2>&1;

# Create configuration and install syslinux bootloader
echo 'Creating syslinux configuration...';

rm -fr /boot/syslinux >/dev/null 2>&1;

if [ ! -f /boot/vmlinuz-linux ]; then
    # Using a custom kernel

    cat > /boot/syslinux.cfg << EOF
default linux
prompt 0
timeout 60

label linux
    menu label Arch Linux (Custom Kernel Configuration)
    linux kernel
    append root=/dev/sda1 ro quiet
EOF

else

    cat > /boot/syslinux.cfg << EOF
default linux
prompt 0
timeout 60

label linux
    menu label Arch Linux
    linux vmlinuz-linux
    append root=/dev/sda1 ro quiet
    initrd initramfs-linux.img
EOF

fi;

echo 'Installing bootloader...';
extlinux -i /boot >/dev/null 2>&1;
dd if=/usr/lib/syslinux/bios/mbr.bin of=/dev/sda bs=440 count=1 >/dev/null 2>&1;

# Create user and disable root login
echo "Creating user $USER...";
useradd -m -s /bin/bash \
    -G audio,network,power,scanner,storage,systemd-journal,video,wheel \
    -U $USER >/dev/null 2>&1;
passwd $USER;

# enable sudo and truecrypt mounting for user
cat >> /etc/sudoers << EOF

$USER ALL=(ALL) ALL
$USER ALL=(root) NOPASSWD:/home/suda/bin/truecrypt
$USER ALL=(root) NOPASSWD:/usr/bin/systemctl restart httpd
$USER ALL=(root) NOPASSWD:/usr/bin/umount -a -t nfs
EOF

echo 'Setting password for root and disabling root login...';
cp /dev/null /etc/securetty >/dev/null 2>&1;
passwd root

# Disable web cam driver from starting automatically
echo 'Disabling web cam...';
cat >> /etc/modprobe.d/modprobe.conf << EOF
blacklist uvcvideo
EOF

# Disable track pad
echo 'Disabling track pad...';
cat >> /etc/modprobe.d/modprobe.conf << EOF
blacklist psmouse
EOF

# Initialize pacman
echo 'Updating pacman mirror list...';
wget 'https://www.archlinux.org/mirrorlist/?country=US&country=DE&country=NL&country=FR&protocol=http&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on' -qO -| \
    sed 's/^#\(.\+\)/\1/g' >/etc/pacman.d/mirrorlist

echo 'Initializing pacman keys...';
systemctl start haveged >/dev/null 2>&1;
pacman-key --init >/dev/null 2>&1;
pacman-key --populate archlinux >/dev/null 2>&1;

echo '';
