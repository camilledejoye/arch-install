#!/bin/bash

readonly bold="\e[1m"
readonly darker="\e[2m"
readonly italic="\e[3m"
readonly underline="\e[4m"

readonly red="\e[31m"
readonly green="\e[32m"
readonly yellow="\e[33m"
readonly blue="\e[34m"
readonly purple="\e[35m"
readonly lightblue="\e[36m"
readonly end="\e[0m"

step() { # {{{
  echo; echo -e "${bold}${blue}>${end} ${bold}${yellow}$1${end}"
} # }}}

error() { # {{{
  if read -t 0; then # Try to read the standard input if possible
    msg="$(cat -)"
  elif [ 1 -lt $# ]; then
    msg="$@"
  fi

  echo -e "${bold}${red}$msg${end}" 1>&2
} # }}}

quit() { # {{{
  error "$@"; exit 1
} # }}}

assert-no-root() { # {{{
  if [ "root" = "$(id --user --name)" ]; then
    quit "This script is not meant to be run as ${yellow}root${end}"
  fi
} # }}}

add-line-to-file() { # {{{
  readonly line="$1"
  readonly file="$2"

  grep -Fxq "$line" "$file" 2>/dev/null || echo "$line" | sudo tee -a "$file" >/dev/null
} # }}}

# vim: ts=2 sw=2 et fdm=marker
