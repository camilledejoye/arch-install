#!/bin/bash

# Variables {{{

repository="https://github.com/camilledejoye/dotfiles"

# }}}

# Install an AUR helper {{{

## Install dependencies to build yay
sudo pacman -S --noconfirm --needed base-devel

## Build yay & cleanup
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg --cleanbuild --syncdeps --install --noconfirm
cd /tmp
rm -fr yay

# }}}

# Install packages {{{

## General packages {{{

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
  dunst \
  vlc \
  alacritty \
  rofi \
  rofi-dmenu \
  feh \
  picom \
  arandr \
  autorandr \
  scrot \
  rcm-git \
  xclip \
  brightnessctl \
  ranger w3m \
  jq \
  udiskie \
  dex \
  pcmanfm \
  qutebrowser

## Install separately because it requires dmenu and this will conflict with rofi-dmenu
## This way rofi-dmenu will validate the requirements without conflicts
## Since --noconfirm will fail if there is a conflict it stops the rest of the script otherwise
yay -S --noconfirm --needed clipmenu

# }}}

## Theme related packages {{{

yay -S --noconfirm --needed \
  lxappearance \
  arc-gtk-theme \
  arc-icon-theme \
  sardi-icons \
  gtk-engine-murrine \
  bibata-cursor-theme-bin

# }}}

## Fonts {{{
yay -S --noconfirm --needed \
  ttf-dejavu \
  ttf-droid \
  ttf-hack \
  ttf-font-awesome \
  ttf-ms-fonts \
  ttf-roboto \
  ttf-ubuntu-font-family \
  noto-fonts \
  terminus-font

# }}}

# }}}

# Configuration {{{

## Install dictionaries for qutebrowser
/usr/share/qutebrowser/scripts/dictcli.py install fr-FR en-US

## Setup X11 keyboard layout (needed for lightdm)
localectl --no-convert set-x11-keymap fr oss terminate:ctrl_alt_bksp,grp:ctrl_rshift_toggle,caps:escape

## Dotfiles {{{

### Clone the dotfiles repository
### Pull only the submodules I'll need
git clone "$repository" \
  -b rcm \
  --recurse-submodules=oh-my-zsh \
  --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-autosuggestions \
  --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-syntax-highlighting \
  --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-vim-mode \
  --recurse-submodules=config/nvim/pack/packager/opt/vim-packager \
  .dotfiles

### Deploy the dotfiles
echo "Deploying the dotfiles..."
# Force the deployement since it's a fresh install
# Don't deploy the vim configuration right now because the plugins require acces to my github
rcup -f -x config/nvim/
echo "Dotfiles deployed."

## }}}

## Enable services {{{

sudo systemctl enable lightdm
systemctl --user enabe ssh-agent.service

## }}}

# }}}

echo -e "\e[1;34m"
echo "The second part of the installation is over"
echo -e "\e[0m"
echo "To continue the installation reboot, login with LightDM"
echo "  and run the last installation script"
echo
echo "$ systemctl reboot"

# vim: ts=2 sw=2 et fdm=marker
