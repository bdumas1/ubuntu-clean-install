#!/usr/bin/env

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
PROGRAMS=(
  "zsh"
  "vim"
  "git"
  "wget"
  "rsync"
  "zip"

  "apache2"
  "php"
  "libapache2-mod-php"
  "mysql-server"
  "php-mysql"

  "php-curl"
  "php-gd"
  "php-intl"
  "php-json"
  "php-mbstring"
  "php-xml"
  "php-zip"
  
  "terminator"
  "gnome-tweak-tool"
  "slack"
  "spotify"
  "nextcloud-client"
  "nextcloud-client-nautilus"
)
HOSTS_FILE_ROWS=(
  "127.0.0.1      money.localhost"
  "192.168.1.26   dsm.bdumas.com"
  "51.15.229.193  bdumas"
)

# Download 1password command line (op) and move it to PATH
download_op() {
  wget $1
  unzip -d $op_directory $zip_filename
  rm $zip_filename
  cd $op_directory
  sudo mv op /usr/local/bin
  rm -rf $op_directory
}

# GET 1password command line with update check
get_op() {
  if ! [ -x "$(command -v op)" ]; then
    op_version="0.10.0"
    zip_filename="op_linux_amd64_v"$op_version".zip"
    op_directory="op"

    download_op https://cache.agilebits.com/dist/1P/op/pkg/v"$op_version"/"$zip_filename"

    # Update op is necessary
    if op update | grep -q 'is available'; then
      op_version=$(op update | cut -f2 -d ' ')
      zip_filename="op_linux_amd64_v"$op_version".zip"

      download_op https://cache.agilebits.com/dist/1P/op/pkg/v"$new_version"/"$zip_filename"
    fi
  fi
}

# Sign in to 1password command line
op_on() {
  if [[ -z $OP_SESSION_my ]]; then
    eval $(op signin my)
  fi
}

# Sign out to 1password command line
op_off() {
  op signout
  unset OP_SESSION_my
}

# Get ssh keys from 1password
get_ssh_keys() {
  sudo mkdir -p "$ssh_dir"
  sudo chmod 700 "$ssh_dir"

  get_op

  op signin my.1password.com $email_address

  op_on

  # Get public/private keys
  op get document "$onepassword_id_rsa" > id_rsa
  op get document "$onepassword_id_rsa_pub" > id_rsa.pub
  mv id_rsa "$ssh_dir"/id_rsa
  mv id_rsa.pub "$ssh_dir"/id_rsa.pub
  cd $ssh_dir
  chmod 600 id_rsa
  chmod 600 id_rsa.pub

  op_off
}

# Get dotfiles and install them
get_dotfiles() {
  dotfiles_folder="dotfiles"

  mkdir -p ~/Lab
  git clone $dotfiles_repo $dotfiles_folder
  cd $dotfiles_folder
  ./install
}

# Install programs
install_programs() {
  # Slack deb
  echo "deb https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" | sudo tee /etc/apt/sources.list.d/slack.list >/dev/null

  # Spotify deb
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null

  # Nextcloud deb
  sudo add-apt-repository ppa:nextcloud-devs/client

  sudo apt update -y

  for program in "${PROGRAMS[@]}"; do
    echo "Installing "$program"..."

    sudo apt install "$program" -y

    echo "$program installed"
  done

  killall nautilus

  # Install NVM
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

  # Install VSCode
  sudo snap install code --classic
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
  for row in "${HOSTS_FILE_ROWS[@]}"; do
    sudo sed -i "$row" /etc/hosts
  done
}

init() {
  sudo apt update -y
  sudo apt upgrade -y

  get_ssh_keys
  install_programs
  get_dotfiles
  change_shell_to_zsh
  update_hosts_file
}

init
