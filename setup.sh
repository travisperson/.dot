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

# This conflicts with i3lock-color-git in yaourt
sudo pacman -Rns --noconfirm i3lock

yaourt -S --noconfirm $(cat yaourt.txt)

# Shared folder is mounted here
sudo mkdir -p /mnt/shared

sudo cp "$BASE/services/vmware-shared-folder.service" /etc/systemd/system/
sudo chmod 0644 "/etc/systemd/system/vmware-shared-folder.service"

# Enable vmware services
sudo systemctl enable vmtoolsd.service
sudo systemctl enable vmware-vmblock-fuse.service
sudo systemctl enable vmware-shared-folder.service
sudo systemctl enable dkms.service

# Sometimes these will show up and screw with the link
rm -rf "$HOME/.config"
rm -rf "$HOME/.vim"

for rc in xinitrc Xdefaults gitconfig vim config; do
  ln -sfv "$BASE/$rc" "$HOME/.$rc"
done

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.apps"

git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# sudo to ignore password prompt
sudo chsh -s $(which fish) $USER

rm -f $HOME/.setup

sudo reboot
