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
  pa-applet-git \
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
  terminus-font \
  ttf-nerd-fonts-symbols

# }}}

# }}}

# Configure LightDM {{{

step "Configure LightDM"

sudo sed -i \
  -e 's/^#\(background\)=$/\1=#1d1f21/' \
  -e 's/^#\(theme-name\)=$/\1=Arc-Dark/' \
  -e 's/^#\(icon-theme-name\)=$/\1=Arc/' \
  -e 's/^#\(indicators\)=$/\1=~spacer;~clock;~spacer;~power/' \
  -e 's/^#\(clock-format\)=$/\1=%A %d %H:%M/' \
  -e 's/^#\(font-name\)=$/\1=Noto Sans/' \
  /etc/lightdm/lightdm-gtk-greeter.conf

add-line-to-file "cursor-theme-name=Bibata-Modern-Ice" "/etc/lightdm/lightdm-gtk-greeter.conf"

# }}}

# Install dictionaries for qutebrowser {{{

step "Install qutebrowser dictionaries"
/usr/share/qutebrowser/scripts/dictcli.py install fr-FR en-US

# }}}

# Setup X11 keyboard layout (needed for lightdm) {{{
step "Setup X11 keyboard layout"
sudo localectl --no-convert set-x11-keymap fr oss terminate:ctrl_alt_bksp,grp:ctrl_rshift_toggle,caps:escape

# }}}

# Deploy the dotfiles {{{

if [ ! -d "$HOME/.dotfiles" ]; then
  step "Setup the dotfiles"

  # Pull only the submodules I'll need
  git clone https://github.com/camilledejoye/dotfiles \
    -b rcm \
    --recurse-submodules=oh-my-zsh \
    --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-autosuggestions \
    --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-syntax-highlighting \
    --recurse-submodules=zsh/oh-my-zsh/plugins/zsh-vim-mode \
    --recurse-submodules=config/nvim/pack/packager/opt/vim-packager \
    "$HOME/.dotfiles"

  git -C "$HOME/.dotfiles" remote set-url origin git@github.com:camilledejoye/dotfiles

  step "Deploying the dotfiles..."
  # Force the deployement since it's a fresh install
  rcup -f
else
  step "Deploying the dotfiles..."
  rcup
fi

## }}}

# Enable services {{{

step "Enable lightdm & the SSH agent"
sudo systemctl enable lightdm
systemctl --user enable ssh-agent.service

# }}}

# Deploy base16 themes {{{

if ! command -v base16-manager >/dev/null 2>&1; then

  step "Deploy base16 theme"

  ## Install my fork of base16-manager
  git clone https://github.com/camilledejoye/base16-manager /tmp/base16-manager
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
fi

# }}}

# Install vim packages {{{

step "Configure NeoVim"

## Needed for CoC & some providers
yay -S --noconfirm --needed nodejs python-pynvim composer yarn

## Needed for Node.js provider
yarn global add neovim

step "Installing packages..."
nvim -c PackInstall -c qa >/dev/null 2>&1

# }}}

echo
echo -e "${bold}${green}The final part of the installation is over${end}"

# vim: ts=2 sw=2 et fdm=marker
