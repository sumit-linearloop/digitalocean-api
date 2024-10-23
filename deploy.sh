#!/bin/bash

# Configuration variables
GIT_REPO="git@github.com:sumit-linearloop/digitalocean-api.git"
BRANCH_NAME="master"
WORK_DIR="/var/www"
APP_NAME="api"  # Name for PM2 process

# Ensure the script runs with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Create work directory if it doesn't exist
echo "Creating work directory: $WORK_DIR"
mkdir -p "$WORK_DIR" || { echo "Failed to create work directory"; exit 1; }

# Set correct permissions
chown -R $USER:$USER "$WORK_DIR"
chmod 755 "$WORK_DIR"

# Navigate to work directory
cd "$WORK_DIR" || { echo "Failed to change to work directory"; exit 1; }

# SSH check to ensure access to the repository
echo "Testing SSH connection to GitHub..."
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "SSH authentication failed. Ensure your SSH key is added to GitHub."
    exit 1
fi

# Clone or update the repository
if [ -d ".git" ]; then
    echo "Repository already exists. Pulling latest changes..."
    git reset --hard || { echo "Failed to reset changes"; exit 1; }
    git clean -fd || { echo "Failed to clean directory"; exit 1; }
    git pull origin "$BRANCH_NAME" || { echo "Failed to pull changes"; exit 1; }
else
    echo "Directory is empty. Cloning repository..."
    git clone -b "$BRANCH_NAME" "$GIT_REPO" . || { echo "Failed to clone repository"; exit 1; }
fi

# Check if Node.js and npm are installed
for cmd in node npm; do
    if ! command -v $cmd &>/dev/null; then
        echo "$cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Install PM2 if not installed
if ! command -v pm2 &>/dev/null; then
    echo "PM2 is not installed. Installing PM2..."
    npm install -g pm2 || { echo "Failed to install PM2"; exit 1; }
fi

# Install dependencies and build the project
echo "Installing dependencies and building..."
yarn install || { echo "Failed to install dependencies"; exit 1; }
yarn build || { echo "Failed to build project"; exit 1; }

# Restart the PM2 process if it exists, otherwise start a new one
if pm2 list | grep -q "$APP_NAME"; then
    echo "Restarting existing PM2 process: $APP_NAME"
    pm2 restart "$APP_NAME" || { echo "Failed to restart PM2 process"; exit 1; }
else
    echo "Starting new PM2 process..."
    pm2 start dist/main.js --name "$APP_NAME" || { echo "Failed to start PM2 process"; exit 1; }
fi

# Save PM2 process list to ensure it starts on reboot
echo "Saving PM2 process list..."
pm2 save || { echo "Failed to save PM2 configuration"; exit 1; }

# Ensure PM2 starts on system boot
echo "Setting PM2 startup..."
pm2 startup systemd -u $USER --hp $HOME || { echo "Failed to set PM2 startup"; exit 1; }

echo "Deployment completed successfully!"
