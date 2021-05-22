#!/bin/bash

# Variables
repository="https://github.com/camilledejoye/dotfiles"

# Install dependencies to build yay
sudo pacman -S --noconfirm --needed base-devel

# Build yay & cleanup
cd /tmp; git clone https://aur.archlinux.org/yay.git
cd yay; makepkg --cleanbuild --syncdeps --install --noconfirm
cd /tmp; rm -fr yay

# Install packages
yay -S --noconfirm --needed \
  xorg \
  lightdm \
  lightdm-gtk-greeter \
  xss-lock \
  sflock-git \
  polkit-gnome-gtk2 \
  gnome-ssh-askpass2 \
  bspwm \
  sxhkd \
  polybar \
  ttf-font-awesome \
  ttf-nerd-fonts-symbols-mono \
  ttf-icomoon-feather \
  dunst \
  vlc \
  alacritty \
  ttf-hack \
  rofi \
  rofi-dmenu \
  feh \
  lxappearance \
  picom \
  arandr \
  autorandr \
  scrot \
  arc-gtk-theme \
  arc-icon-theme \
  gnome-themes-extra \
  gtk-engine-murrine \
  rcm-git \
  xclip \
  brightnessctl \
  clipmenu \
  ranger w3m \
  jq \
  udiskie \
  dex \
  qutebrowser

# Enable lightdm
sudo systemctl enable lightdm

# Setup X11 keyboard layout (needed for lightdm)
localectl --no-convert set-x11-keymap fr oss terminate:ctrl_alt_bksp,grp:ctrl_rshift_toggle,caps:escape

# Clone the dotfiles repository
# Pull only the submodules I'll need
git clone "$repository" \
  -b rcm \
  --recurse-submodules=oh-my-zsh \
  --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-autosuggestions \
  --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-syntax-highlighting \
  --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-vim-mode \
  .dotfiles

# Deploy the dotfiles

echo "Deploying the dotfiles..."
# Force the deployement since it's a fresh install
# Don't deploy the vim configuration right now because the plugins require acces to my github
rcup -f -x config/nvim/
echo "Dotfiles deployed."

# Enable user services from the dotfiles
systemctl --user enabe ssh-agent.service

echo -e "\e[1;34m"
echo "The second part of the installation is over"
echo -e "\e[0m"
echo "To continue the installation reboot, login with LightDM"
echo "  and run the last installation script"
echo
echo "$ systemctl reboot"

# vim: ts=2 sw=2 et
