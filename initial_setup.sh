#!/bin/bash

# Function to check if a command exists
check_command() {
  command -v "$1" &> /dev/null
}

# Function to verify if NVM is properly loaded
verify_nvm() {
  if check_command nvm; then
    echo "NVM is loaded."
  else
    echo "NVM is not loaded. Trying to load manually..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if check_command nvm; then
      echo "NVM successfully loaded."
    else
      echo "Failed to load NVM. Exiting."
      exit 1
    fi
  fi
}

# Update package index and install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y git curl jq nginx
sudo snap install aws-cli --classic

# Set up SSH directory
echo "Setting up SSH directory..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add GitHub to known hosts
echo "Adding GitHub to known hosts..."
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Set up SSH key for Git
echo "Setting up SSH key for Git..."
echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

echo "Setup AWS CLI..."
aws configure set aws_access_key_id "${AWS_ACCESS_KEY}"
aws configure set aws_secret_access_key "${AWS_SECRET_KEY}"
aws configure set region "${AWS_REGION}"

# Install NVM
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Ensure .bashrc exists for root user
if [ ! -f ~/.bashrc ]; then
    echo "Creating .bashrc..."
    touch ~/.bashrc
fi

# Add NVM and npm paths to .bashrc
echo "Adding NVM and npm paths to .bashrc..."
{
    echo 'export NVM_DIR="$HOME/.nvm"'
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'
    echo 'export PATH="$PATH:$HOME/.npm-global/bin:$NVM_DIR/versions/node/$(nvm version)/bin"'
} >> ~/.bashrc

# Source the updated .bashrc
echo "Sourcing .bashrc..."
source ~/.bashrc

# Verify that NVM is loaded
verify_nvm

# Install Node.js
echo "Installing Node.js..."
nvm install "${NODE_VERSION}"

# Install Yarn and PM2
echo "Installing Yarn and PM2..."
npm install -g yarn pm2

echo "Initial setup completed successfully!"
