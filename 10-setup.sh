#!/bin/bash

# Load the helper if not already loaded (when including in another script)
if ! type 'quit' >/dev/null 2>&1; then
  readonly current_dir="$( cd "$( dirname "$0" )" ; pwd -P )"
  . "$current_dir/lib.sh"
fi

# Keep current values if already defined and use sensible defaults otherwise
skip_mirrors=${skip_mirrors:-1}
country=${country:-France}
user=${user:-$(id -u --name)}

# Install packages {{{

## Update mirrors
sudo pacman -S --noconfirm --needed rsync reflector
if [ 0 -eq $skip_mirrors ]; then
  step "Update the mirrors..."
  reflector -c "$country" -l 200 --sort rate --save /etc/pacman.d/mirrorlist
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
sudo pacman -S --noconfirm --needed nvidia nvidia-utils nvidia-settings

# Enable if in a virtualbox VM
# sudo pacman -S --noconfirm --needed virtualbox-guest-utils
# sudo systelctm enable vboxservice.service

# }}}

# Enable the services {{{

step "Enable the services"
sudo systemctl enable NetworkManager
sudo systemctl enable cups
sudo systemctl enable sshd
sudo systemctl enable reflector.timer
sudo systemctl enable acpid

# }}}

# Generate a new SSH key for the user {{{

if [ ! -f "/home/$user/.ssh/id_ed25519" ]; then
  step "Generate an SSH key for ${yellow}$user${end}"

  cmd="ssh-keygen -t ed25519 -f '/home/$user/.ssh/id_ed25519'"
  [ ! -z "$passphrase" ] cmd="$cmd -N '$passphrase'"

  if [ "$(id -u --name)" = "$user" ]; then
    eval "$cmd"
  else
    su "$user" -c "$cmd"
  fi
fi

# }}}

# Configure the shell {{{

readonly user_shell=$(getent passwd $user | awk -F: '{print $NF}')
if [ $(which zsh) != "$user_shell" ]; then
  step "Define ${yellow}zsh${end} as default shell for ${yellow}$user${end}"
  sudo usermod -s "$(which zsh)" "$user"
fi

step "Enable starship"
for shell in "bash\nzsh"; do
  line="eval \"\$(starship init $shell)\""
  grep -Fxq "$line" "/home/$user/.${shell}rc" || echo "$line" >> "/home/$user/.${shell}rc"
done

# }}}

# vim: ts=2 sw=2 et fdm=marker
