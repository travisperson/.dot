#!/usr/bin/env bash

iface=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | tr -d ' ')

sudo dhcpcd $iface; sleep 5
sudo pacman -Syu
sudo pacman -S --noconfirm - < $HOME/dot/pacman.txt

# This conflicts with i3lock-color-git in yaourt
sudo pacman -Rns --noconfirm i3lock

yaourt -S --noconfirm $(cat $HOME/dot/yaourt.txt)

rm -f /home/travis/.setup
