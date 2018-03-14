#!/usr/bin/env bash

iface=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | tr -d ' ')

sudo dhcpcd $iface; sleep 5
sudo pacman -Syu
sudo pacman -S --noconfirm - < $HOME/dot/pacman.txt
# yaourt -S --noconfirm - < yaourt.txt

rm -f /home/travis/.setup
