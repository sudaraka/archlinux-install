#!/bin/sh
# ex2-remount-target.sh: Remount the installation destinations like 010 script
#
#   Copyright 2014 Sudaraka Wijesinghe <sudaraka.org/contact>
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
echo 'ex2-remount-target Copyright 2014 Sudaraka Wijesinghe';
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

HOME_PARTITION=${DEV1}5


########### Unmount existing partitions and virtual file systems ##############

for MOUNT_POINT in `mount|grep /mnt/|cut -d' ' -f3`; do
    echo "Unmounting $MOUNT_POINT";
    umount -v $MOUNT_POINT >/dev/null 2>&1;
done;

umount -v /mnt >/dev/null 2>&1;

########### Unmount existing partitions and virtual file systems ##############


########### Mount partitions and virtual file systems #########################

# Mount root
echo 'Mounting root partition...';
mount /dev/${DEV1}1 /mnt >/dev/null;

# Mount home
echo 'Mounting home partition...';
mount /dev/${HOME_PARTITION} /mnt/home >/dev/null;

if [ ! -z $DEV2 ]; then
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
