#!/bin/bash

# Variables
hostname="cdejoye-arch"
user="cdejoye"

# Set the root password
echo "Set the password for the user 'root':"
passwd; echo

# Create my user
useradd -m "$user"
echo "Set the password for the user '$user':"
passwd "$user"; echo
pacman -S --noconfirm --needed sudo
echo "$user ALL=(ALL) ALL" > "/etc/sudoers.d/$user"

# Update mirrors
pacman -S --noconfirm --needed rsync reflector
reflector -c France -l 200 --sort rate --save /etc/pacman.d/mirrorlist

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# Localization
pacman -S --noconfirm --needed sed
sed -i 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^#\(fr_FR.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf

# Keyboard layout for TTYs
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf

# Network
echo "$hostname" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.local $hostname" >> /etc/hosts

# Bootloader
pacman -S --noconfirm --needed grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Install packages
pacman -S --noconfirm --needed \
  man-db \
  man-pages \
  mlocate \
  pacman-contrib \
  zsh \
  starship \
  bat \
  fzf \
  ripgrep \
  neovim \
  htop \
  usbutils \
  wget \
  networkmanager \
  network-manager-applet \
  wpa_supplicant \
  net-tools \
  inetutils \
  dnsutils \
  bridge-utils \
  dnsmasq \
  iptables \
  cups \
  hplip \
  alsa-utils \
  pulseaudio \
  pulseaudio-alsa \
  pavucontrol \
  openssh \
  acpi \
  acpi_call \
  acpid \
  ntfs-3g \
  which \
  xdg-user-dirs \
  xdg-utils

## Disable if not using a nvidia cards
pacman -S --noconfirm --needed nvidia nvidia-utils nvidia-settings

## Enable if in a virtualbox VM
# pacman -S --noconfirm --needed virtualbox-guest-utils
# systelctm enable vboxservice.service

# Enable the newly installed services
systemctl enable NetworkManager
systemctl enable cups.service
systemctl enable sshd
systemctl enable reflector.timer
systemctl enable acpid

# Generate a new SSH key for the user
su "$user" -c "ssh-keygen -t ed25519 -f '/home/$user/.ssh/id_ed25519' -N ''"

# Configure the shell
usermod -s "$(which zsh)" "$user"
echo 'eval "$(starship init bash)"' >> "/home/$user/.bashrc"
echo 'eval "$(starship init zsh)"' >> "/home/$user/.zshrc"
## For fish just in case
#mkdir -p "/home/$user/.config/fish"
#echo "starship init fish | source" >> "/home/$user/.config/fish/config.fish"

echo -e "\e[1;34m"
echo "The first part of the installation is over"
echo -e "\e[0m"
echo "To continue the installation move the scripts to your home directory"
echo "  exit the system, unmount your filesytem and reboot"
echo
echo "$ mv arch-install \"/home/$user\""
echo "$ exit"
echo "$ umount -R /mnt"
echo "$ reboot"

# vim: ts=2 sw=2 et
