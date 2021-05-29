#!/bin/bash

# Warning
echo -e "\e[1;33m"
echo "Register the SSH key in github before going any further !"
echo -e "\e[0m"
echo "Press <Enter> to continue..."; read

# Variables
remote_url="git@github.com:camilledejoye"

# Update dotfiles remote so I can push changes
$(cd "$HOME/.dotfiles"; git remote set-url origin "$remote_url/dotfiles")

# Password-store
yay -S --noconfirm --needed pass
$(cd "$HOME"; git clone "$remote_url/password-store" .password-store)

# Install vim packages {{{

## Needed for CoC & some providers
yay -S --noconfirm --needed nodejs python-pynvim composer yarn

## Needed for Node.js provider
yarn global add neovim

## Deploy config
rcup config/nvim

echo "Installing packages, it might take a while..."
nvim -c PackInstall -c qa >/dev/null 2>&1

# }}}

# Deploy base16 themes {{{

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

# }}}

echo -e "\e[1;34m"
echo "To use the password-store, first import the private & public keys !"
echo -e "\e[0m"
echo "gpp --import public.key private.key"
echo "gpg --edit-key {ID} trust quit"
echo "rm -f public.key priate.key"

# vim: ts=2 sw=2 et fdm=marker
