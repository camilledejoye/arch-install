#!/bin/bash

# Load the helper functions
readonly current_dir="$( cd "$( dirname "$0" )" ; pwd -P )"
. "$current_dir/lib.sh"

# Ensure logged in as root
[ 0 -ne $(id -u) ] && quit "You must be root"

## Define variables & read arguments {{{

user="cdejoye"
skip_mirrors=0

while [ -n "${1-}" ]; do
  case "$1" in
    -u|--user)
      user="$2"; shift ;;

    -h|--hostname)
      hostname="$2"; shift;;

    --skip-mirrors)
      skip_mirrors=1 ;;
  esac

  shift
done

## Default value if not provided
hostname="${hostname:-$user-arch}"

# }}}

# Set the root password
step "Set the password for the ${blue}root${yellow} user:"
passwd; echo

# Create the main user {{{

step "Create the user ${blue}$user${end}"
if id "$user" >/dev/null 2>&1; then
  echo -e "The user already exists."
else
  useradd -m "$user"
  echo -e "User created."
  passwd "$user"
  pacman -S --noconfirm --needed sudo
  echo "$user ALL=(ALL) ALL" >> "/etc/sudoers.d/$user"
  # Grants sudo privilege as root to $user without having to type a password for 2 hours
  echo "$user ALL=(root) NOTAFTER=$(date --utc -d "+2 hours" +%Y%m%d%H%MZ) NOPASSWD: ALL" >> "/etc/sudoers.d/$user"
fi

# }}}

# Locale setup {{{

if [ ! -f /etc/localtime ]; then
  step "Set up the timezone and locale..."

  ## Set the timezone
  ln -sf "/usr/share/zoneinfo/Europe/Paris" /etc/localtime
  hwclock --systohc

  ## Generate the locales
  pacman -S --noconfirm --needed sed
  sed -i 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
  sed -i 's/^#\(fr_FR.UTF-8\)/\1/' /etc/locale.gen
  locale-gen

  ## Setup the locales
  echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
  echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf
  echo "LC_TIME=en_US.UTF-8" >> /etc/locale.conf

  ## Keyboard layout for TTYs
  echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
fi

# }}}

# Network {{{

step "Set up the hostname & updating ${blue}/etc/hosts${end}"
echo "$hostname" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.local $hostname" >> /etc/hosts

# }}}

# Bootloader {{{

step "Set up the bootloader"
pacman -S --noconfirm --needed grub efibootmgr os-prober intel-ucode
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# }}}

# Install packages {{{

## Update mirrors
sudo pacman -S --noconfirm --needed rsync reflector
if [ 0 -eq $skip_mirrors ]; then
  step "Update the mirrors..."
  sudo reflector -c "$country" -l 200 --sort rate --save /etc/pacman.d/mirrorlist
fi

step "Install default packages"
sudo pacman -S --noconfirm --needed \
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
  gnupg \
  dialog \
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

# Disable if not using a nvidia cards
pacman -S --noconfirm --needed nvidia nvidia-utils nvidia-settings

# Enable if in a virtualbox VM
# pacman -S --noconfirm --needed virtualbox-guest-utils
# systemctl enable vboxservice.service

# }}}

# Enable the services {{{

step "Enable the services"
sudo systemctl enable NetworkManager
sudo systemctl enable cups
sudo systemctl enable sshd
sudo systemctl enable reflector.timer
sudo systemctl enable acpid

# }}}

step "Moving installation scripts to ${blue}/home/$user/arch-install${end}"
mv arch-install "/home/$user"
chown -R cdejoye. "/home/$user/arch-install"

echo
echo -e "${bold}${green}The first part of the installation is over${end}"
echo "To continue the installation exit the system, unmount your filesytem and reboot"
echo
echo "$ exit"
echo "$ umount -R /mnt"
echo "$ reboot"

# vim: ts=2 sw=2 et fdm=marker
