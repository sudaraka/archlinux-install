#!/bin/sh
# 052-install-gui.sh: Install GUI
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
echo '052-install-gui Copyright 2013, 2014 Sudaraka Wijesinghe';
echo 'This program comes with ABSOLUTELY NO WARRANTY;';
echo 'This is free software, and you are welcome to redistribute it';
echo 'under certain conditions under GNU GPLv3 or later.';
echo '';


if [ 0 -eq $UID ]; then
    echo 'Please run as normal user';
    exit 1;
fi;


# install X, fonts and iBus
yaourt -S --noconfirm \
    xorg-server xorg-utils xorg-server-utils xorg-xinit mesa mesa-demos \
    ttf-dejavu ttf-droid ttf-lklug monaco-powerline-font-git \
    gvfs gtk-engine-{unico,murrine} \
    ibus

case "$1" in
    "xfce")
        # install XFCE
        yaourt -S --noconfirm --ignore mousepad \
            xfce4 xfce4-goodies xfce4-places-plugin
        ;;
    "i3")
        # install i3
        yaourt -S --noconfirm \
            i3 dmenu thunar thunar-archive-plugin ristretto tumbler \
            xfce4-screenshooter conky
        ;;
esac;

# Other software
yaourt -S --noconfirm \
    chromium dropbox thunar-dropbox pidgin-libnotify \
    transmission-gtk keepassx claws-mail gimp vlc dnsutils libreoffice-fresh \
    gnucash gnome-calculator evince aspell-en hunspell-en ispell filezilla \
    geany-plugins meld ghex tree dosfstools ntfs-3g file-roller unrar zip \
    unzip p7zip arj php-apache mariadb-clients tk pkgfile screen cmake \
    the_silver_searcher

# Make Python 2.x default
sudo rm /bin/python >/dev/null 2>&1;
sudo ln -s python2 /bin/python >/dev/null 2>&1;
