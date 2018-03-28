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

for rc in bin; do
  ln -sfv "$BASE/$rc" "$HOME/$rc"
done

mkdir -p "$HOME/.vim/backup"
mkdir -p "$HOME/.vim/undo"
mkdir -p "$HOME/.vim/swap"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.apps"

git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
vim +GoInstallBinaries

# sudo to ignore password prompt
sudo chsh -s $(which fish) $USER

# Start shared folder to transfer files
sudo systemctl start vmware-shared-folder.service

# Copy ssh keys / config
cp -r /mnt/shared/.ssh/ $HOME/.ssh/

# Attach to repo
git init
git remote add origin git@github.com:travisperson/.dot.git
git fetch origin
git reset origin/master

# asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.4.3
cp $HOME/.asdf/completions/asdf.fish $HOME/.config/fish/completions

source $HOME/.asdf/asdf.sh

asdf plugin-add golang
asdf plugin-add nodejs
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

asdf install golang 1.10
asdf global golang 1.10

asdf install nodejs 9.9.0
asdf global nodejs 9.9.0

rm -f $HOME/.setup

# sudo reboot
