#!/bin/bash

# Load the helper if not already loaded (when including in another script)
if ! type 'quit' >/dev/null 2>&1; then
  readonly current_dir="$( cd "$( dirname "$0" )" ; pwd -P )"
  . "$current_dir/lib.sh"
fi

assert-not-root

# Install packages {{{

step "Install packages"

## General packages {{{

yay -S --noconfirm --needed \
  xf86-video-intel \
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
  nerd-fonts-hack \
  ttf-font-awesome \
  ttf-ms-fonts \
  ttf-roboto \
  ttf-ubuntu-font-family \
  noto-fonts \
  terminus-font

# }}}

# }}}

# Install dictionaries for qutebrowser {{{

step "Install qutebrowser dictionaries"
/usr/share/qutebrowser/scripts/dictcli.py install fr-FR en-US

# }}}

# Setup X11 keyboard layout (needed for lightdm) {{{
step "Setup X11 keyboard layout"
localectl --no-convert set-x11-keymap fr oss terminate:ctrl_alt_bksp,grp:ctrl_rshift_toggle,caps:escape

# }}}

# Deploy the dotfiles {{{

dotfiles_dir="$HOME/.dotfiles"

if [ ! -d "$dotfiles_dir" ]; then
  step "Setup the dotfiles"

  # Pull only the submodules I'll need
  git clone git@github.com:camilledejoye/dotfiles \
    -b rcm \
    --recurse-submodules=oh-my-zsh \
    --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-autosuggestions \
    --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-syntax-highlighting \
    --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-vim-mode \
    --recurse-submodules=config/nvim/pack/packager/opt/vim-packager \
    "$dotfiles_dir"

  step "Deploying the dotfiles..."
  # Force the deployement since it's a fresh install
  rcup -f
else
  step "Deploying the dotfiles..."
  rcup
fi

## }}}

## Enable services {{{

step "Enable lightdm & the SSH agent"
sudo systemctl enable lightdm
systemctl --user enabe ssh-agent.service

## }}}

# Deploy base16 themes {{{

## Install my fork of base16-manager
git clone git@github.com:base16-manager /tmp/base16-manager
cd /tmp/base16-manager
sudo make install

## Install the themes needed
base16-manager install theova/base16-qutebrowser
base16-manager install nicodebo/base16-fzf
base16-manager install khamer/base16-dunst
base16-manager install chriskempson/base16-xresources
base16-manager install chriskempson/base16-vim
# Not sure yet for rofi because I think my theme is based on the colors but not the look
# base16-manager install 0xdec/base16-rofi

## Setup the theme
base16-manager set tomorrow-night

# }}}

# Setup the password store {{{

step "Setup the password store"
yay -S --noconfirm --needed pass
git clone git@github.com:camilledejoye/password-store "$HOME/.password-store"

# }}}

echo -e "${bold}${green}The second part of the installation is over${end}"
echo
echo "To use the password-store, first import the private & public keys !"
echo "$ gpp --import public.key private.key"
echo "$ gpg --edit-key {ID} trust quit"
echo "$ rm -f public.key priate.key"

# vim: ts=2 sw=2 et fdm=marker
