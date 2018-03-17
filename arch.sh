#!/bin/bash

PACMAN_CACHE="/dev/sdb1"
PRIMARY_DEVICE="/dev/sda"

USER="travis"
HOSTNAME="black"
DOMAIN="travis.fyi"
HOME="/home/$USER"
DOT_TAR="https://api.github.com/repos/travisperson/.dot/tarball"

#
# Time
#

timedatectl set-ntp true

#
# Disk partition
#

PD_MAX_SECTORS=$(blockdev --getsz "$PRIMARY_DEVICE")

sfdisk "$PRIMARY_DEVICE" <<EOF
label: gpt
label-id: B0F48A5F-CB93-4C3F-8992-222217998248
device: $PRIMARY_DEVICE
unit: sectors
first-lba: 2048
last-lba: $((PD_MAX_SECTORS - 2048))

${PRIMARY_DEVICE}1 : start=        2048, size=                       2048, type=21686148-6449-6E6F-744E-656564454649, uuid=E88EB8CC-ADB4-6040-B3DA-1754D18368BA
${PRIMARY_DEVICE}2 : start=        4096, size= $((PD_MAX_SECTORS - 4096)), type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=D02DD14B-A49F-F845-80E3-29EC929C7A95
EOF

# Format the second parittion as ext4

mkfs.ext4 "${PRIMARY_DEVICE}2"

#
# Initial disk setup
#

# Mount primary

mount "${PRIMARY_DEVICE}2" /mnt

# Setup pacman cache

mkdir -p /mnt/var/cache/pacman/pkg
mount "$PACMAN_CACHE" /mnt/var/cache/pacman/pkg

#
# Initial Install
#

pacstrap /mnt base base-devel i3 xorg xorg-apps xorg-drivers

#
# Generate fstab
#

genfstab -U /mnt >> /mnt/etc/fstab

#
# Post chroot setup script
#

cat > /mnt/root/setup.sh <<EOFSUB

#
# Timezone / locale
#

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

sed -i -e "/#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" -e "/#en_US ISO-8859-1/c\en_US ISO-8859-1" /etc/locale.gen

locale-gen

cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF

#
# Enable passwordless sudo for easy setup
#

sed -i -e "/# %wheel ALL=(ALL) NOPASSWD: ALL/c\%wheel ALL=(ALL) NOPASSWD: ALL" /etc/sudoers

#
# Hostname / host file setup
#

cat > /etc/hostname <<EOF
$HOSTNAME.$DOMAIN
EOF

cat > /etc/hosts <<EOF
127.0.0.1            localhost.localdomain localhost
::1                  localhost.localdomain localhost
127.0.1.1            $HOSTNAME.$DOMAIN $HOSTNAME
EOF

#
# Setup Grub
#

pacman -Sy --noconfirm grub
grub-install --target=i386-pc "$PRIMARY_DEVICE"
grub-mkconfig -o /boot/grub/grub.cfg

#
# User setup
#

useradd -m $USER -d $HOME -G wheel
passwd -d $USER

mkdir $HOME/.dot
curl -L $DOT_TAR | tar xz -C $HOME/.dot --strip=1

chown -R $USER:$USER $HOME

#
# Yaourt
#

cat >> /etc/pacman.conf <<EOF

[archlinuxfr]
SigLevel = Never
Server = https://repo.archlinux.fr/\\\$arch
EOF

#
# Post login setup
#

cat >> $HOME/.bash_profile <<EOF
[[ -f ~/.setup ]] && sh ~/.setup
EOF

ln -s $HOME/.dot/setup.sh $HOME/.setup

exit

EOFSUB

#
# chroot install
#

arch-chroot /mnt /bin/bash -c "/bin/bash /root/setup.sh"

#
# Cleanup mounted dirs
#

umount /mnt/var/cache/pacman/pkg
umount /mnt

reboot
