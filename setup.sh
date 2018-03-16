#!/usr/bin/env bash

cd "$(dirname $(readlink "${BASH_SOURCE[0]}"))" || exit 1

BASE=$(pwd)
IFACE=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | tr -d ' ')

echo $BASE

sleep 10;

sudo cat /proc/version > /etc/arch-release

sudo dhcpcd $IFACE; sleep 5
sudo pacman -Syu
sudo pacman -S --noconfirm - < pacman.txt

systemctl enable vmtoolsd.service
systemctl enable vmware-vmblock-fuse.service
systemctl enable dkms.service

# This conflicts with i3lock-color-git in yaourt
sudo pacman -Rns --noconfirm i3lock

yaourt -S --noconfirm $(cat yaourt.txt)

# Sometimes these will show up and screw with the link
rm -rf "$HOME/.config"
rm -rf "$HOME/.vim"

for rc in xinitrc Xdefaults gitconfig vim config; do
  ln -sfv "$BASE/$rc" "$HOME/.$rc"
done

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.apps"

git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

curl -L https://dl.google.com/go/go1.10.linux-amd64.tar.gz | tar xz -C $HOME/.apps

# sudo to ignore password prompt
sudo chsh -s $(which fish) $USER

rm -f $HOME/.setup
