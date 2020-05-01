#!/usr/bin/env bash

# Exit when a command fails
set -o errexit

# Exit when use undeclared variables
set -o nounset

# variables needed for the install
email_address="dumasbenoit1@gmail.com"
ssh_dir=~/.ssh
onepassword_id_rsa="id_rsa - PERSO"
onepassword_id_rsa_pub="id_rsa.pub - PERSO"
dotfiles_repo="git@gitlab.com:Geetix/dotfiles.git"

init() {
  remove_sources_list_files

  sudo apt update -y
  sudo apt upgrade -y

  get_ssh_keys
  install_programs
  get_dotfiles
  change_shell_to_zsh
  update_hosts_file
}

# Get ssh keys from 1password
get_ssh_keys() {
  sudo mkdir -p "$ssh_dir"
  sudo chmod 700 "$ssh_dir"

  if [ ! -f "$ssh_dir"/id_rsa ] && [ ! -f "$ssh_dir"/id_rsa.pub ]; then
    ./op get_op

    op signin my.1password.com $email_address

    ./op op_on

    # Get public/private keys
    op get document "$onepassword_id_rsa" > id_rsa
    op get document "$onepassword_id_rsa_pub" > id_rsa.pub
    mv id_rsa "$ssh_dir"/id_rsa
    mv id_rsa.pub "$ssh_dir"/id_rsa.pub
    cd $ssh_dir
    chmod 600 id_rsa
    chmod 600 id_rsa.pub

    ./op op_off
  fi
}

# Get dotfiles and install them
get_dotfiles() {
  dotfiles_folder="dotfiles"
  lab_folder=~/Lab

  if [ ! -d "$lab_folder"/"$dotfiles_folder" ]; then
    mkdir -p "$lab_folder"
    cd "$lab_folder"
    git clone $dotfiles_repo $dotfiles_folder
    cd $dotfiles_folder
    ./install
  fi
}

# Remove some sources list files if exists
remove_sources_list_files() {
  FILES=(
    "/etc/apt/sources.list.d/spotify.list"
    "/etc/apt/sources.list.d/spotify.list.save"
  )

  for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
      sudo rm -rf "$file"
    fi
  done
}

# Install programs
install_programs() {
  ./programs/apt_install
  ./programs/snap_install

  # Install NVM
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
}

# Set ZSH to default shell
change_shell_to_zsh() {
  echo "Changing shell to ZSH..."

  chsh -s $(which zsh)
  echo "Shell is set to ZSH for $(whoami)"

  sudo chsh -s $(which zsh)
  echo "Shell is set to ZSH for root"
}

# Add rules to hosts file
update_hosts_file() {
  sudo chmod 744 ./manage-etc-hosts.sh

  ./manage-etc-hosts.sh add money.localhost 127.0.0.1
  ./manage-etc-hosts.sh add dsm.bdumas.com 192.168.1.26
  ./manage-etc-hosts.sh add bdumas 51.15.229.193
}

init "$@"
