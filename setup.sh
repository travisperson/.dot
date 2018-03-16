#!/usr/bin/env bash

iface=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | tr -d ' ')

sudo dhcpcd $iface; sleep 5
sudo pacman -Syu
sudo pacman -S --noconfirm - < $HOME/dot/pacman.txt

# This conflicts with i3lock-color-git in yaourt
sudo pacman -Rns --noconfirm i3lock

yaourt -S --noconfirm $(cat $HOME/dot/yaourt.txt)

ln -sf $HOME/dot/vim $HOME/.vim
ln -sf $HOME/dot/config $HOME/.config

mkdir .apps/go

curl -L https://dl.google.com/go/go1.10.linux-amd64.tar.gz | tar xz -C $HOME/.apps

rm -f $HOME/.setup
