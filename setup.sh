#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

BASE=$(pwd)
IFACE=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | tr -d ' ')

sudo dhcpcd $iface; sleep 5
sudo pacman -Syu
sudo pacman -S --noconfirm - < pacman.txt

# This conflicts with i3lock-color-git in yaourt
sudo pacman -Rns --noconfirm i3lock

yaourt -S --noconfirm $(cat yaourt.txt)

for rc in xinitrc Xdefaults gitconfig vim config; do
  ln -sfv "$BASE/$rc" $HOME/."$rc"
done

git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

mkdir $HOME/.apps/go

curl -L https://dl.google.com/go/go1.10.linux-amd64.tar.gz | tar xz -C $HOME/.apps

chsh -s $(which fish) $USER

rm -f $HOME/.setup
