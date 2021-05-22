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
echo -e "\e[1;34m"
echo "To use the password-store, first import the private & public keys !"
echo -e "\e[0m"
echo "gpp --import public.key private.key"
echo "gpg --edit-key {ID} trust quit"
echo "rm -f public.key priate.key"

# Install vim packages

## Needed for CoC & some providers
yay -S --noconfirm --needed nodejs python-pynvim composer

## Needed for Node.js provider
yarn global add neovim

## Deploy config
rcup config/nvim

echo "Installing packages, it might take a while..."
nvim -c PackInstall -c qa >/dev/null 2>&1

# vim: ts=2 sw=2 et
