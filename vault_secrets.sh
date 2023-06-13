#!/bin/bash

# Enable secrets path using kv-v2
if ( vault secrets list -format=json | jq -e '.["secrets/"]' > /dev/null )
then 
  echo -e "\n\033[1;32m==== Secrets path enabled ====\033[0m\n"
else
  echo -e "\n\033[1;33m==== Enabling secrets path ====\033[0m\n"
  vault secrets enable -path=secrets kv-v2
fi

# Store json in secrets path
if [ -f test.json ]
then
  echo -e "\n\033[1;32m==== Putting Json in secrets/new_secret ====\033[0m\n"
  vault kv put secrets/data/new_secret @test.json
else
  echo -e "\n\033[1;33m==== Json file test.json not found ====\033[0m\n"
fi

# Get json secrets
if ( vault kv get -format=json secrets/data/new_secret > /dev/null 2>&1 )
then 
  echo -e "\n\033[1;32m==== Get json secrets ====\033[0m\n"
  vault kv get secrets/data/new_secret
else
  echo -e "\n\033[1;31m==== No secret found at secrets/data/new_secret ====\033[0m\n"
fi

# Get user names from secrets
vault kv get -format=json secrets/data/new_secret | jq -r '.data.data.users[] | .name'

# Get user email from secrets
vault kv get -format=json secrets/data/new_secret | jq -r '.data.data.users[].email'

# Get users password from secrets
vault kv get -format=json secrets/data/new_secret | jq -r '.data.data.secrets.database.password'
