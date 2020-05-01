#!/usr/bin/env bash

install() {
  echo "Installing via snap: "$1"..."
  sudo snap install "$1" $2
}

install zoom-client

install code --classic
install slack --classic