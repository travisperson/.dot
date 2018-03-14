#!/bin/bash

timedatectl set-ntp true

timedatectl status
fdisk -l

sfdisk /dev/sda <<EOF
label: dos
label-id: 0xbb31c7d4
device: /dev/sda
unit: sectors

/dev/sda1 : start= 2048, size= 2048, type=4
/dev/sda2 : start= 4096, size= 41938944, type=83
EOF

mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt

pacstrap /mnt base base-devel i3 xorg xorg-apps xorg-drivers

genfstab -U /mnt >> /mnt/etc/fstab

cat > /mnt/root/setup.sh <<EOFSUB

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

sed -i -e "/#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" -e "/#en_US ISO-8859-1/c\en_US ISO-8859-1" /etc/locale.gen
sed -i -e "/# %wheel ALL=(ALL) ALL/c\%wheel ALL=(ALL) ALL" /etc/sudoers

locale-gen

cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF

cat > /etc/hostname <<EOF
black.travis.fyi
EOF

cat > /etc/hosts <<EOF
127.0.0.1            localhost.localdomain localhost
::1                  localhost.localdomain localhost
127.0.1.1            black.travis.fyi      myhostname
EOF

pacman -Sy --noconfirm grub

grub-install --target=i386-pc /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg

useradd -m travis -G wheel
passwd -d travis

mkdir /home/travis/dot
curl -L https://api.github.com/repos/travisperson/.dot/tarball | tar xz -C /home/travis/dot --strip=1

chown -R travis:travis /home/travis

cat >> /etc/pacman.conf <<EOF

[archlinuxfr]
SigLevel = Never
Server = https://repo.archlinux.fr/\$arch
EOF

cat >> /home/travis/.bash_profile <<EOF
[[ -f ~/.setup ]] && sh ~/.setup
EOF

ln -s /home/travis/dot/setup.sh /home/travis/.setup

exit

EOFSUB

arch-chroot /mnt /bin/bash -c "/bin/bash /root/setup.sh"

reboot
