#!/bin/bash

# Configuration variables
GIT_REPO="git@github.com:sumit-linearloop/digitalocean-api.git"
BRANCH_NAME="master"
WORK_DIR="$HOME/app"  # Use home directory for permissions
SERVER_IP="128.199.28.236"  # Replace with your server IP
SERVER_HOSTNAME="root"  # Replace with your server hostname

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

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js and try again."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install npm and try again."
    exit 1
fi

# Check if PM2 is installed, if not install it
if ! command -v pm2 &> /dev/null; then
    echo "PM2 is not installed. Installing PM2..."
    npm install -g pm2 || { echo "Failed to install PM2"; exit 1; }
fi

# Install dependencies and build
echo "Installing dependencies and building..."
yarn install || { echo "Failed to install dependencies"; exit 1; }
yarn build || { echo "Failed to build project"; exit 1; }

# Check if PM2 process exists
if pm2 list | grep -q "api"; then
    echo "PM2 process exists. No restart command executed."
else
    echo "Starting new PM2 process..."
    pm2 start dist/main.js --name "api" || { echo "Failed to start PM2 process"; exit 1; }
fi

# Save PM2 configuration
pm2 save || { echo "Failed to save PM2 configuration"; exit 1; }

echo "Deployment completed successfully!"
