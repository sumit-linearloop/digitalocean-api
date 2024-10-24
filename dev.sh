#!/bin/bash

# Configuration variables
GIT_REPO="git@github.com:sumit-linearloop/digitalocean-api.git"
BRANCH_NAME="DEV"
WORK_DIR="/var/www/dev"
SECRET_NAME="dev"  # Name of the secret in AWS Secrets Manager

# Function to handle errors
handle_error() {
    echo "$1" >&2
    exit 1
}

# Function to check and install/update Node.js if necessary
check_node_installed() {
    if ! command -v node &> /dev/null; then
        echo "Node.js not found. Installing..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -  # Install Node.js 18.x
        apt-get install -y nodejs || handle_error "Failed to install Node.js"
    else
        NODE_VERSION=$(node -v)
        echo "Current Node.js version: $NODE_VERSION"
        # Check if the current Node.js version is compatible
        if [[ "$NODE_VERSION" < "v18.20.0" ]]; then
            echo "Updating Node.js to the latest version..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -  # Change version as needed
            apt-get install -y nodejs || handle_error "Failed to update Node.js"
        else
            echo "Node.js is already installed and is compatible."
        fi
    fi
}

npm install -g pm2


# Function to check and install Yarn if not found
check_yarn_installed() {
    if ! command -v yarn &> /dev/null; then
        echo "Yarn not found. Installing..."
        npm install --global yarn|| handle_error "Failed to install Yarn"
    else
        echo "Yarn is already installed."
    fi
}

# Create work directory if it doesn't exist
echo "Creating work directory: $WORK_DIR"
mkdir -p "$WORK_DIR" || handle_error "Failed to create work directory"

# Navigate to work directory
cd "$WORK_DIR" || handle_error "Failed to change to work directory"

# Check if directory is empty and clone the repository
if [ -z "$(ls -A "$WORK_DIR")" ]; then
    echo "Cloning repository..."
    git clone -b "$BRANCH_NAME" "$GIT_REPO" . || handle_error "Failed to clone repository"
else
    echo "Directory is not empty. Pulling latest changes..."
    git pull origin "$BRANCH_NAME" || handle_error "Failed to pull latest changes"
fi

# Fetch secret from AWS Secrets Manager
echo "Retrieving secrets from AWS Secrets Manager..."
if aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text | jq -r 'to_entries | map("\(.key)=\(.value)") | .[]' > "$WORK_DIR/.env"; then
    echo "Secrets retrieved successfully and saved to .env"
else
    handle_error "Failed to retrieve secrets from AWS Secrets Manager"
fi

# Check if Node.js is installed and install if necessary
check_node_installed

# Check if Yarn is installed and install if necessary
check_yarn_installed

# Install dependencies and build
echo "Installing dependencies and building..."
yarn install || handle_error "Failed to install dependencies"
yarn build || handle_error "Failed to build project"

# Check if PM2 process exists and start it
echo "Starting new PM2 process..."
pm2 start dist/main.js --name "app" || handle_error "Failed to start PM2 process"

# Save PM2 configuration
pm2 save || handle_error "Failed to save PM2 configuration"
