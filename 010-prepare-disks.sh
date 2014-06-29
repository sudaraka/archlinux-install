#!/bin/sh
# 010-prepare-disks.sh: Partition and format disks for new installation
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
echo '010-prepare-disks Copyright 2013 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';

DEV1=$1
shift
DEV2=$1

# Validate first parameter (device 1)
if [ ! -b /dev/$DEV1 ]; then
    echo "'$DEV1' is not a valid block device.";
    exit 1;
fi;

# Validate second parameter (device 2)
if [[ ! -z $DEV2 && ! -b /dev/$DEV2 ]]; then
    echo "'$DEV2' is not a valid block device.";
    exit 1;
fi;

# Make sure devices 1 & 2 are not the same
if [[ "$DEV1" == "$DEV2" ]]; then
    echo 'Switching to single disk setup';
    DEV2=''
fi;


########### Remove LVM partitions from device mapper ##########################

if [ ! -z "`dmsetup ls|grep -v arch_root-image`" ]; then
    dmsetup remove_all >/dev/null 2>&1;
fi;

########### Remove LVM partitions from device mapper ##########################


########### Prepare Device 1 ##################################################

echo "Create partitions on /dev/$DEV1";

echo "Erasing data and partitions..."
dd if=/dev/zero of=/dev/$DEV1 bs=1024 count=1024 >/dev/null 2>&1;

# Create partition for /
echo 'Creating primary partition and extended partition for the rest...'
fdisk /dev/$DEV1 >/dev/null 2>&1 <<EOF
n
p
1

+10G
a
n
e
2


w
EOF

# Create partition for /home
echo 'Creating logical partition for /home in remaining space...';
fdisk /dev/$DEV1 >/dev/null 2>&1 <<EOF
n
l
5


w
EOF

# Print the result
fdisk -l /dev/$DEV1 2>/dev/null;

echo '';

########### Prepare Device 1 ##################################################


########### Prepare Device 2 ##################################################

if [ ! -z $DEV2 ]; then
    echo "Create partitions on /dev/$DEV2";

    echo "Erasing data and partitions...";
    dd if=/dev/zero of=/dev/$DEV2 bs=1024 count=1024 >/dev/null 2>&1;

    # Create partition for /
    echo 'Creating extended partition...';
    fdisk /dev/$DEV2 >/dev/null 2>&1 <<EOF
n
e
1


n
l
5


w
EOF

    # Print the result
    fdisk -l /dev/$DEV2 2>/dev/null;

    echo '';

fi;

########### Prepare Device 2 ##################################################


########### Format partitions #################################################

# Format root partition as ext4
echo "Formatting root : /dev/${DEV1}1...";
mkfs.ext4 /dev/${DEV1}1 >/dev/null 2>&1;

# Format home partition as ext4
HOME_PARTITION=${DEV1}5

echo "Formatting home : /dev/${HOME_PARTITION}...";
mkfs.ext4 /dev/${HOME_PARTITION} >/dev/null 2>&1;

# Format extra partition as ext4
if [ ! -z $DEV2 ]; then
    echo "Formatting disk2: /dev/${DEV2}5...";
    mkfs.ext4 /dev/${DEV2}5 >/dev/null 2>&1;
fi;

echo '';

########### Format partitions #################################################


########### Mount partitions and virtual file systems #########################

# Mount root
echo 'Mounting root partition...';
mount /dev/${DEV1}1 /mnt >/dev/null;

# Create directory structure on root partition
echo 'Creating directory structure on root partition...';
mkdir -p /mnt/{boot,dev,etc/wpa_supplicant,home,proc,root,run,sys,tmp,var/{cache/pacman/pkg,lib/pacman}} 2>/dev/null;

# Mount home
echo 'Mounting home partition...';
mount /dev/${HOME_PARTITION} /mnt/home >/dev/null;

if [ ! -z $DEV2 ]; then
    mkdir -p /mnt/disk2 >/dev/null;

    # Mount disk2
    echo 'Mounting disk2 partition...';
    mount /dev/${DEV2}5 /mnt/disk2
fi;

# Mount virtual file systems for chroot
echo 'Mounting and binding virtual file systems for chroot...';
mount -t devtmpfs udev /mnt/dev >/dev/null;
mount -t proc proc /mnt/proc >/dev/null;
mount -t sysfs sys /mnt/sys >/dev/null;
mount --bind /tmp /mnt/tmp >/dev/null;

########### Mount partitions and virtual file systems #########################


########### Create swap file ##################################################

SWAP_PARTITION=/mnt/boot/swap

echo "Creating swap file : ${SWAP_PARTITION}...";
dd if=/dev/zero of=$SWAP_PARTITION bs=1M count=2048 >/dev/null 2>&1;
chmod 600 $SWAP_PARTITION >/dev/null 2>&1
mkswap ${SWAP_PARTITION} >/dev/null 2>&1;

# Switch swap to new file
echo 'Switching to swap file...';
swapon ${SWAP_PARTITION} >/dev/null;

echo '';

########### Create swap file ##################################################
