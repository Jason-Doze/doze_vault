# Doze_Vault

This repo provides a fully automated solution for setting up, configuring, and utilizing HashiCorp's Vault on a Raspberry Pi 400 running Ubuntu Server from MacOS. Through a series of scripts, it automates the entire process of installing, starting, and managing secrets with Vault to secure sensitive data.

## Structure

`pi_local.sh:` This script connects to a Raspberry Pi 400 running Ubuntu Server, synchronizes the local directory with the Pi, executes commands on the Pi, and logs in.

`vault_install.sh`: This script handles the installation of Vault on Raspberry Pi. It updates package lists, installs GPG, downloads the Hashicorp signing key, adds the Hashicorp repository, and installs Vault.

`vault_start.sh`: This script sets up and starts the Vault server. It installs JQ, sets the VAULT_ADDR environment variable, creates a Vault data directory, configures the Vault server, and validates that the server is running. 
Following these initial steps, it also initializes Vault, during which unseal keys and a root token are generated. The user will need to copy these directly from the terminal output for the subsequent steps. The script will then prompt the user to enter the unseal keys directly into the terminal to unseal the Vault. 
Note that the Vault must be unsealed before it can be accessed. Lastly, the script logs into Vault using the root token copied from the initial output.

`vault_secrets.sh`: This script demonstrates interaction with Vault's key-value secrets engine. It enables the key-value secrets engine at a specific path. Then creates a new secret at the designated path by passing a JSON file containing key-value pairs of the secret data. Finally, it retrieves the secret data from the path, showing how users can access the stored secrets.

## Prerequisites
* Raspberry Pi 400 running Ubuntu server.
* SSH service enabled on your Raspberry Pi.
* Pi hostname set to pi.

## Usage
1. Set the PI_HOST variable to the IP address of your Raspberry Pi and run the pi_local.sh script:

```bash
PI_HOST=$(dig +short pi | tail -n1) bash pi_local.sh
```

## Important

* The root token is a privileged token with superuser permissions. Keep it safe and do not share it.
After a restart, you'll need to unseal the Vault again to access it.
* If you lose your root token and have no other way to log in to Vault, you'll have to reinitialize the Vault. Note, this will erase all your data stored in the Vault.