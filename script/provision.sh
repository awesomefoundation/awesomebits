#!/bin/sh

# Stop script execution as soon as there are any errors
set -e

# Use the en_GB.utf8 locale
sudo update-locale LANG=en_GB.utf8

# Install the packages we need
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git ruby-full

# Set up things like a database, Ruby, and Rails in here.

# Set shell login message
echo "-----------------------------------------------
Put some instructions in here, to be shown
whenever anyone SSHes into the VM.
-----------------------------------------------
" | sudo tee /etc/motd.tail > /dev/null
