#!/usr/bin/env bash

install() {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

install curl

# Spotify source
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Nextcloud source
sudo add-apt-repository ppa:nextcloud-devs/client

sudo apt update -y

install zsh
install vim
install git
install wget
install rsync
install zip

# LAMP
install apache2
install php
install libapache2-mod-php
install mysql-server
install php-mysql
install php-curl
install php-gd
install php-intl
install php-json
install php-mbstring
install php-xml
install php-zip

# Apps
install terminator
install gnome-tweak-tool
install spotify-client
install nextcloud-client
install nextcloud-client-nautilus