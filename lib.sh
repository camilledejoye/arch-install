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

step() {
  echo; echo -e "${bold}${blue}>${end} ${bold}${yellow}$1${end}"
}

error() {
  echo -e "${bold}${red}$1${end}" >2
}

quit() {
  error "$1"; exit 1
}

# vim: ts=2 sw=2 et fdm=marker
