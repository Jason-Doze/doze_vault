#!/bin/bash

# This script updates the package list, sets the VAULT_ADDR environment variable, installs Jq, creates a Vault data directory, configures the Vault server, validates the Vault server is running, initializes Vault, and unseals Vault.

sudo apt update

# Set VAULT_ADDR environment variable
export VAULT_ADDR='http://127.0.0.1:8200'

# Install JQ
if ( which jq > /dev/null )
then 
  echo -e "\n\033[1;32m==== JQ is present ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Installing JQ ====\033[0m\n"
  sudo apt install -y jq
fi

# Create Vault data directory
if [ -d /home/jasondoze/doze_vault/vault/data ]
then 
  echo -e "\n\033[1;32m==== Vault data directory present ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Creating Vault data directory ====\033[0m\n"
  mkdir -p /home/jasondoze/doze_vault/vault/data
fi

# Configure Vault server
if [ -f /home/jasondoze/doze_vault/config.hcl ]
then 
  echo -e "\n\033[1;32m==== Vault server configuration present ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Configuring Vault server ====\033[0m\n"
cat <<- EOF > /home/jasondoze/doze_vault/config.hcl
storage "raft" {
  path    = "/home/jasondoze/doze_vault/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"
ui = true
EOF
fi

# Start the Vault server
if ( nc -z 127.0.0.1 8200 > /dev/null 2>&1 )
then 
  echo -e "\n\033[1;32m==== Vault server is started ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Starting Vault server ====\033[0m\n"
  nohup vault server -config=/home/jasondoze/doze_vault/config.hcl > /dev/null 2>&1 &
fi
  
# Wait for the Vault server to start
while true
do
  if ( nc -z 127.0.0.1 8200 > /dev/null 2>&1 )
  then
    echo -e "\n\033[1;32m==== Vault server is running ====\033[0m\n"
    break
  else
    printf "\033[31m.\033[0m"
    sleep 0.1
  fi
done

# Check Vault initialization status
if [ "$(vault status -format=json | jq -r '.initialized')" = "true" ]
then 
  echo -e "\n\033[1;32m==== Vault is already initialized ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Initializing Vault ====\033[0m\n"
  vault operator init
fi

# Check if Vault is sealed
if [ "$(vault status -format=json | jq -r '.sealed')" = "false" ]
then 
  echo -e "\n\033[1;32m==== Vault is unsealed ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Vault is sealed. Unsealing now... ====\033[0m\n"
  vault operator unseal
fi