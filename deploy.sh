#!/bin/bash

# Configuration variables
GIT_REPO="git@github.com:sumit-linearloop/digitalocean-api.git"
BRANCH_NAME="master"
WORK_DIR="~/master"  # Use home directory for permissions

# Function to check SSH connection
check_ssh_connection() {
    echo "Testing SSH connection to GitHub..."
    if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "Error: SSH authentication failed!"
        echo "Please ensure:"
        echo "1. SSH key is generated (ssh-keygen -t rsa -b 4096)"
        echo "2. Public key is added to GitHub (cat ~/.ssh/id_rsa.pub)"
        exit 1
    fi
}

# Start SSH agent
eval $(ssh-agent -s)

# Add SSH key to agent
ssh-add ~/.ssh/id_rsa || echo "Note: Could not add SSH key to agent"

# Check SSH connection before proceeding
check_ssh_connection

# Create work directory if it doesn't exist
echo "Creating work directory: $WORK_DIR"
mkdir -p "$WORK_DIR" || { echo "Failed to create work directory"; exit 1; }

# Navigate to work directory
cd "$WORK_DIR" || { echo "Failed to change to work directory"; exit 1; }

# Check if directory is empty
if [ "$(ls -A $WORK_DIR)" ]; then
    echo "Directory is not empty. Pulling latest changes..."
    git pull origin "$BRANCH_NAME" || { echo "Failed to pull changes"; exit 1; }
else
    echo "Directory is empty. Cloning repository..."
    git clone "$GIT_REPO" . || { echo "Failed to clone repository"; exit 1; }
    git checkout "$BRANCH_NAME" || { echo "Failed to checkout branch"; exit 1; }
fi

# Install dependencies and build
echo "Installing dependencies and building..."
yarn install || { echo "Failed to install dependencies"; exit 1; }
yarn build || { echo "Failed to build project"; exit 1; }

# Check if PM2 process exists
if pm2 list | grep -q "DEV"; then
    echo "Restarting PM2 process..."
    pm2 restart "DEV" || { echo "Failed to restart PM2 process"; exit 1; }
else
    echo "Starting new PM2 process..."
    pm2 start dist/main.js --name "DEV" || { echo "Failed to start PM2 process"; exit 1; }
fi

# Save PM2 configuration
pm2 save || { echo "Failed to save PM2 configuration"; exit 1; }

echo "Deployment completed successfully!"
