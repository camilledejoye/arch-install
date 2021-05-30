#!/bin/bash

# Load the helper functions
readonly current_dir="$( cd "$( dirname "$0" )" ; pwd -P )"
. "$current_dir/lib.sh"

# Ensure logged in as root
[ 0 -ne $(id -u) ] && quit "You must be root"

## Define variables & read arguments {{{

user="cdejoye"
hostname=""
skip_mirrors=0

while [ -n "${1-}" ]; do
  case "$1" in
    -u|--user)
      user="$2"; shift ;;

    -h|--hostname)
      hostname="$2"; shift;;

    -p|--passphrase)
      passphrase="$2"; shift;;

    --skip-mirrors)
      skip_mirrors=1 ;;
  esac

  shift
done

## Default value if not provided
[ -z "$hostname" ] && hostname="$user-arch"

## Ask for the SSH passphrase if not provided
if [ -z "$passphrase" ]; then
  step "Setup SSH information"
  echo -n "Enter a passphrase for the user's SSH key:"
  while [ -z "$passphrase" ]; do
    echo
    echo -n "Passphrase: "
    stty -echo
    read passphrase
    stty echo
  done
fi

# }}}

# Set the root password
step "Set the password for the ${yellow}root${end} user:"
passwd; echo

# Create the main user {{{

step "Create the user ${yellow}$use${end}"
if id "$user" >/dev/null 2>&1; then
  echo -e "The user already exists."
else
  useradd -m "$user"
  echo -e "User created."
  passwd "$user"
  pacman -S --noconfirm --needed sudo
  echo "$user ALL=(ALL) ALL" > "/etc/sudoers.d/$user"
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

  ## Keyboard layout for TTYs
  echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
fi

# }}}

# Network {{{

step "Set up the hostname & updating ${yellow}/etc/hosts${end}"
echo "$hostname" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.local $hostname" >> /etc/hosts

# }}}

# Bootloader {{{

step "Set up the bootloader"
pacman -S --noconfirm --needed grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# }}}

# Install Yay {{{

step "Install Yay"

pacman -S --noconfirm --needed base-devel

# Grant permission run makepkg without having to type a password
echo "$user ALL=(root) NOPASSWD: /usr/bin/pacman" >> "/etc/sudoers.d/$user"

# Install as the main user since makepkg is blocked as root
su "$user" <<'EOF'
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg --noconfirm --syncdeps --install
EOF

# Remove the extra permission
sed -i "/^$user.*pacman$/d" "/etc/sudoers.d/$user"

# }}}

# Setup the system
. "$current_dir/10-setup.sh"

step "Moving installation scripts to ${yellow}/home/$user/arch-install${end}"
mv arch-install "/home/$user"

echo -e "${bold}${green}The first part of the installation is over${end}"
echo "To continue the installation exit the system, unmount your filesytem and reboot"
echo
echo "$ exit"
echo "$ umount -R /mnt"
echo "$ reboot"

# vim: ts=2 sw=2 et fdm=marker
