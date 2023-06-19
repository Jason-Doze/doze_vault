#!/bin/bash

# This script updates the package list, sets the VAULT_ADDR environment variable, installs JQ, creates a Vault data directory, configures the Vault server, validates the Vault server is running, initializes Vault, and unseals Vault.

# Update Apt
if ( apt-cache show jq &> /dev/null )
then
  echo -e "\n\033[1;32m==== JQ in cache ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Updating Apt ====\033[0m\n"
  sudo apt update 
fi

# Install JQ
if ( which jq > /dev/null ) 
then
  echo -e "\n\033[1;32m==== JQ installed ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Installing JQ ====\033[0m\n"
  sudo apt install -y jq
fi

# Export VAULT_ADDR
if ( grep -q "export VAULT_ADDR='http://127.0.0.1:8200'" ~/.bashrc )
then
  echo -e "\n\033[1;33m==== VAULT_ADDR in bashrc ====\033[0m\n"
else
  echo -e "\n\033[1;32m==== Adding VAULT_ADDR to bashrc ====\033[0m\n"
  echo "export VAULT_ADDR='http://127.0.0.1:8200'" >> ~/.bashrc
  export VAULT_ADDR='http://127.0.0.1:8200'
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
cluster_addr = "https://127.0.0.1:8201"
ui = true
EOF
fi

# Start the Vault server
if ( nc -z 127.0.0.1 8200 &> /dev/null )
then 
  echo -e "\n\033[1;32m==== Vault server is started ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Starting Vault server ====\033[0m\n"
  nohup vault server -config=/home/jasondoze/doze_vault/config.hcl &> vault.log &
fi
  
# Wait for the Vault server to start
while true
do
  if ( nc -z 127.0.0.1 8200 &> /dev/null )
  then
    echo -e "\n\033[1;32m==== Vault server is running ====\033[0m\n"
    break
  else
    printf "\033[31m.\033[0m"
    sleep 2
  fi
done

# Initialize Vault
if [ "$(vault status -format=json | jq -r '.initialized')" = "true" ]
then 
  echo -e "\n\033[1;32m==== Vault is already initialized ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Initializing Vault ====\033[0m\n"
  vault operator init
fi

# Unseal Vault
if [ "$(vault status -format=json | jq -r '.sealed')" = "false" ]
then 
  echo -e "\n\033[1;32m==== Vault is unsealed ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Unsealing Vault  ====\033[0m\n"
  # Outer loop cycles 3 times
  for i in {1..3}
  do
    # Inner loop allows up to 5 attempts to unseal Vault
    for attempt in {1..5}
    do
      echo -e "\n\033[1;33m==== Enter unseal key (attempt $attempt) ====\033[0m\n"
      if ( vault operator unseal )
      then
        echo -e "\n\033[1;32m==== Unseal key applied ====\033[0m\n"
        # Validate Vault is unsealed after each attempt
        if [ "$(vault status -format=json | jq -r '.sealed')" = "false" ]
        then 
          echo -e "\n\033[1;32m==== Vault is unsealed ====\033[0m\n"
          # Break nested loops when Vault is unsealed
          break 2  
        fi
      else
        echo -e "\n\033[1;31m==== Incorrect key, try again ====\033[0m\n"
      fi
    done
  done
  # Validate Vault sealed after all attempts
  if [ "$(vault status -format=json | jq -r '.sealed')" = "true" ]
  then
    echo -e "\n\033[1;31m==== Vault could not be unsealed ====\033[0m\n"
    # Exit with error status if Vault could not be unsealed
    exit 1  
  fi
fi

# Login to Vault
if [ "$(vault status -format=json | jq -r '.sealed')" = "true" ]
then 
  echo -e "\n\033[1;31m==== Vault is sealed, cannot login ====\033[0m\n"
else
  echo -e "\n\033[1;32m==== Logging into Vault, enter root token ====\033[0m\n"
  vault login
fi
