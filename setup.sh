#!/usr/bin/env bash

sudo dhcpcd ens33; sleep 5
sudo pacman -Syu
sudo pacman -S --noconfirm - < $HOME/dot/pacman.txt
# yaourt -S --noconfirm - < yaourt.txt

rm -f /home/travis/.setup
