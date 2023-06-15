#!/bin/bash

# This script demonstrates interaction with Vault's key-value secrets engine. It enables the key-value secrets engine at a specific path, creates a new secret at the designated path by passing a JSON file, which contains the key-value pairs of the secret data, and retrieves the secret data from the path, showing how users can access the stored secrets.

# Sleep 5 seconds for Vault login process to finish
sleep 10

# Enable secrets path using kv-v2
if ( vault secrets list -format=json | jq -e '.["secrets/"]' > /dev/null )
then 
  echo -e "\n\033[1;32m==== Secrets path enabled ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Enabling secrets path ====\033[0m\n"
  vault secrets enable -path=secrets kv-v2
fi

# Store json in secrets path
if ( vault kv get -format=json secrets/data/new_secret )
then
  echo -e "\n\033[1;32m==== Json file test.json in secrets/new_secret ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Putting Json in secrets/new_secret ====\033[0m\n"
  vault kv put secrets/data/new_secret @test.json
fi

# Get user names from secrets
vault kv get -format=json secrets/data/new_secret | jq -r '.data.data.users[] | .name'
echo
# Get user email from secrets
vault kv get -format=json secrets/data/new_secret | jq -r '.data.data.users[].email'
echo
# Get users password from secrets
vault kv get -format=json secrets/data/new_secret | jq -r '.data.data.secrets.database.password'
