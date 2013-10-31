#!/bin/sh
# 040-unmount-disks.sh: Unmount partitions/filesystems used for installation.
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
echo '040-unmount-disks Copyright 2013 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';

# Turn off swap
echo 'Turning swap off...';
swapoff -a;

echo '';

# Unmount installation partitions
for MOUNT_POINT in `mount|grep /mnt/|cut -d' ' -f3`; do
    echo "Unmounting $MOUNT_POINT";
    umount -v $MOUNT_POINT >/dev/null 2>&1;
done;

echo "Unmounting /mnt";
umount -v /mnt >/dev/null 2>&1;

# Unmount NFS pacman cache
if [ ! -z "`mount|grep /var/cache/pacman`" ]; then
    echo "Unmounting /var/cache/pacman/pkg";
    umount -v /var/cache/pacman/pkg >/dev/null 2>&1;
fi;

if [ ! -z "`mount|grep /var/lib/pacman/sync`" ]; then
    echo "Unmounting /var/lib/pacman/sync";
    umount -v /var/lib/pacman/sync >/dev/null 2>&1;
fi;

echo '';
