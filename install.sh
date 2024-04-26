#!/usr/bin/env bash

read -p "Enter app id (see flathub.org): " appid

if ! command -v flatpak &> /dev/null
then
  echo "Could not find flatpak, installing..."
  ./install/flatpak.sh
fi

sudo flatpak install flathub "$appid" -y --noninteractive --verbose
