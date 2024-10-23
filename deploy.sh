#!/bin/bash

# Configuration variables
GIT_REPO="git@github.com:sumit-linearloop/digitalocean-api.git"
BRANCH_NAME="master"
WORK_DIR="$HOME/master"  # Use a directory in the home folder

# Function to check SSH connection
check_ssh_connection() {
    echo "Testing SSH connection to GitHub..."
    if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "Error: SSH authentication failed!"
        echo "Please ensure:"
        echo "1. SSH key is generated (ssh-keygen -t rsa -b 4096)"
        echo "2. Public key is added to GitHub (cat ~/.ssh/id_rsa.pub)"
        echo "3. SSH agent is running (eval \$(ssh-agent -s))"
        echo "4. SSH key is added to agent (ssh-add ~/.ssh/id_rsa)"
        exit 1
    fi
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Start SSH agent if not running
eval $(ssh-agent -s) > /dev/null

# Add SSH key to agent
ssh-add ~/.ssh/id_rsa 2>/dev/null || echo "Note: Could not add SSH key to agent"

# Check SSH connection before proceeding
check_ssh_connection

# Create work directory if it doesn't exist
echo "Creating work directory: $WORK_DIR"
mkdir -p "$WORK_DIR" || handle_error "Failed to create work directory"

# Navigate to work directory
cd "$WORK_DIR" || handle_error "Failed to change to work directory"

# Check if directory is empty
if [ "$(ls -A $WORK_DIR)" ]; then
    echo "Directory is not empty. Pulling latest changes..."
    git pull origin "$BRANCH_NAME" || handle_error "Failed to pull changes"
else
    echo "Directory is empty. Cloning repository..."
    git clone "$GIT_REPO" . || handle_error "Failed to clone repository"
    git checkout "$BRANCH_NAME" || handle_error "Failed to checkout branch"
fi

# Check for Node.js and yarn installation
if ! command -v node &> /dev/null; then
    handle_error "Node.js is not installed. Please install Node.js."
fi

if ! command -v yarn &> /dev/null; then
    handle_error "Yarn is not installed. Please install Yarn."
fi

# Install dependencies and build
echo "Installing dependencies and building..."
yarn install || handle_error "Failed to install dependencies"
yarn build || handle_error "Failed to build project"

# Check if PM2 process exists
if pm2 list | grep -q "DEV"; then
    echo "Restarting PM2 process..."
    pm2 restart "DEV" || handle_error "Failed to restart PM2 process"
else
    echo "Starting new PM2 process..."
    pm2 start dist/main.js --name "DEV" || handle_error "Failed to start PM2 process"
fi

# Save PM2 configuration
pm2 save || handle_error "Failed to save PM2 configuration"

echo "Deployment completed successfully!"
