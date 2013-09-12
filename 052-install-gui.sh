#!/bin/sh
# 052-install-gui.sh: Install GUI
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
echo '052-install-gui Copyright 2013 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';

# install X, XFCE, fonts and iBus
yaourt -S --noconfirm --ignore mousepad \
    xorg-server xorg-utils xorg-server-utils xorg-xinit mesa mesa-demos \
    ttf-dejavu ttf-droid ttf-lklug \
    xfce4 xfce4-goodies xfce4-places-plugin gvfs \
    gtk-engine-{unico,murrine} \
    ibus

mkdir -p $HOME/src >/dev/null 2>&1;
cd $HOME/src >/dev/null 2>&1;

# Install themes and icons
git clone https://github.com/duskp/numix-holo.git 2>&1;
git clone https://github.com/shimmerproject/elementary-xfce.git 2>&1;

ln -s $HOME/src/numix-holo /usr/share/themes >/dev/null 2>&1;
ln -s $HOME/src/elementary-xfce/elementary-xfce /usr/share/icons \
    >/dev/null 2>&1;
ln -s $HOME/src/elementary-xfce/elementary-xfce-dark /usr/share/icons \
     >/dev/null 2>&1;
