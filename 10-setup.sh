#!/bin/bash

# Load the helper if not already loaded (when including in another script)
if ! type 'quit' >/dev/null 2>&1; then
  readonly current_dir="$( cd "$( dirname "$0" )" ; pwd -P )"
  . "$current_dir/lib.sh"
fi

assert-not-root

# Variables {{{

while [ -n "${1-}" ]; do
  case "$1" in
    -p|--passphrase)
      passphrase="$2"; shift;;

    -g|--github-token)
      github_token="$2"; shift;;
  esac

  shift
done

## Ask for the SSH passphrase if not provided {{{

if [ ! -f "$HOME/.ssh/id_ed25519" -a -z "$passphrase" ]; then
  step "Setup SSH information"
  echo -n "Enter a passphrase for the user's SSH key (press enter for no passphrase):"
  stty -echo
  read passphrase
  stty echo
fi

# }}}

## Decode the GitHub token {{{

step "Decoding the GitHub token"

sudo pacman -S --noconfirm --needed gnupg

count_attempt=0
while ! github_token="$(gpg -dq "$current_dir/github-token.gpg" 2>/dev/null)"; do
  count_attempt=$((count_attempt + 1))

  [ 3 -eq $count_attempt ] && break
done

# }}}

# }}}

# Install Yay {{{

step "Install Yay"

sudo pacman -S --noconfirm --needed base-devel

# Install as the main user since makepkg is blocked as root
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg --noconfirm --syncdeps --install

# }}}

# Generate a new SSH key for the user {{{

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  step "Generate an SSH key for ${blue}$USER${end}"

  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "${passphrase:-}"
fi

# }}}

# Register SSH key to GitHub {{{

if [ ! -z "${github_token:-}" ]; then
  step "Registering the SSH key to GitHub"

  curl -u "camilledejoye:$github_token" \
    -H "Accept: application/vnd.github.v3+json" \
    -X POST https://api.github.com/user/keys \
    --write-out "%{http_code}\n" \
    --silent --output /dev/null \
    --data-binary @-  <<EOF
{
  "title":"$(hostname) - test",
  "key":"$(cat /home/cdejoye/.ssh/id_ed25519.pub)"
}
EOF
fi

# }}}

# Configure the shell {{{

if [ $(which zsh) != "${SHELL:-}" ]; then
  step "Define ${blue}zsh${yellow} as default shell for ${blue}$USER${yellow}"
  sudo usersmod -s "$(which zsh)" "$USER"
fi

if [ -z "${STARSHIP_SHELL:-}" ]; then
  step "Enable starship"

  for shell in bash zsh; do
    line="eval \"\$(starship init $shell)\""
    grep -Fxq "$line" "$HOME/.${shell}rc" 2>/dev/null || echo "$line" >> "$HOME/.${shell}rc"
  done
fi

# }}}

# Update pacman configuration {{{

step "Update pacman configuration"
sudo sed -i -e 's/^#\(Color\)$/\1/' \
  -e 's/^#\(TotalDownload\)$/\1/' \
  -e 's/^#\(VerbosePkgLists\)$/\1/' \
  -e 's/^# Misc options$/\0\nILoveCandy/' \
  /etc/pacman.conf

# }}}

# Install a graphical environment
. "$current_dir/20-bspwm.sh"

# vim: ts=2 sw=2 et fdm=marker
