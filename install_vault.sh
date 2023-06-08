#!/bin/bash

# This script updates the package list, installs Gpg, downloads the Hashicorp signing key, adds the Hashicorp repository and installs Vault.
sudo apt update

# Install Gpg
if ( which gpg > /dev/null )
then
  echo -e "\n\033[1;32m==== Gpg present ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Installing Gpg ====\033[0m\n"
  sudo apt install gpg
fi

# Download signing key
if [ -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]
then
  echo -e "\n\033[1;32m==== Hashicorp keyring present ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Downloading Hashicorp signing key  ====\033[0m\n"
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
fi

# Add Hashi repo and install Vault
if [ -f /etc/apt/sources.list.d/hashicorp.list ]
then
  echo -e "\n\033[1;32m==== Vault present ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Adding Hashicorp repo and installing Vault ====\033[0m\n"
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install vault
fi