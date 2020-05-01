#!/usr/bin/env bash

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
  eval $(op signin my)
}

# Sign out to 1password command line
op_off() {
  op signout
  unset OP_SESSION_my
}

$@