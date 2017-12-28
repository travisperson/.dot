#!/usr/bin/env bash

sudo pacman -Syu
sudo pacman -S --noconfirm - < pacman.txt
# yaourt -S --noconfirm - < yaourt.txt

rm -f /home/travis/.setup
