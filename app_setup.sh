#!/bin/bash

# Function to set up an application
setup_app() {
  local app_name=$1
  local repo_url=$2
  local domain_name=$3
  local port=$4
  local secret=$5
  local branch_name=$6

  echo "Setting up $app_name..."
  
  # Source NVM script to ensure Node.js and Yarn are available
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
      echo "Sourcing NVM..."
      source "$NVM_DIR/nvm.sh"
  else
      echo "NVM not found, please install NVM."
      exit 1
  fi

  # Verify NVM and use the correct Node version
  nvm use default || { echo "Failed to set Node version"; exit 1; }

  # Clone or update the repository
  if [ -d "/var/www/$app_name" ]; then
    echo "$app_name already exists. Updating..."
    cd "/var/www/$app_name"
    git checkout "$branch_name"  # Switch to the desired branch
    git pull origin "$branch_name"  # Pull the latest changes from that branch
  else
    # Clone the specified branch
    git clone -b "$branch_name" "$repo_url" "/var/www/$app_name"
    cd "/var/www/$app_name"
  fi


aws secretsmanager get-secret-value --secret-id $secret --query SecretString --output text | jq -r 'to_entries | map("\(.key)=\(.value)") | .[]' > "/var/www/$app_name/.env"

  # Install dependencies and build
  echo "Installing project dependencies..."
  yarn install

  echo "Building project..."
  yarn build

  # Set up PM2
  echo "Setting up PM2..."
  pm2 stop "$app_name" || echo "PM2 service not running"
  pm2 delete "$app_name" || echo "No PM2 process to delete"
  pm2 start dist/main.js --name "$app_name" -i 1 || { echo "PM2 start failed"; exit 1; }
  pm2 save || { echo "PM2 save failed"; exit 1; }

  # Set up Nginx
  echo "Setting up Nginx for domain: $domain_name..."
  NGINX_CONF="/etc/nginx/sites-available/$domain_name"
  sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $domain_name;

    location / {
        proxy_pass http://localhost:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

  # Enable the site and reload Nginx
  sudo ln -sf /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx
}

# Function to destroy an application setup
destroy_app() {
  local app_name=$1
  local repo_url=$2
  local domain_name=$3
  local port=$4
  local secret=$5
  local branch_name=$6
    # Source NVM script to ensure Node.js and Yarn are available
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
      echo "Sourcing NVM..."
      source "$NVM_DIR/nvm.sh"
  else
      echo "NVM not found, please install NVM."
      exit 1
  fi

  # Ensure pm2 is in the path
  export PATH=$PATH:$(npm bin -g)

  echo "Destroying $app_name setup..."
  
  # Stop and delete PM2 process
  pm2 stop "$app_name" || echo "PM2 service not running"
  pm2 delete "$app_name" || echo "No PM2 process to delete"
  pm2 save --force || { echo "PM2 save failed"; exit 1; }

  # Remove the application directory
  rm -rf "/var/www/$app_name"

  # Remove Nginx configuration
  sudo rm -f "/etc/nginx/sites-available/$domain_name"
  sudo rm -f "/etc/nginx/sites-enabled/$domain_name"
  sudo nginx -t && sudo systemctl reload nginx

  echo "$app_name destroyed successfully."
}

# Main execution
case "$1" in
  "setup_dragonfly")
    setup_app "dragonfly" "$DRAGONFLY_REPO" "$DRAGONFLY_DOMAIN" "$DRAGONFLY_PORT" "$DRAGONFLY_SECRET" "$DRAGONFLY_BRANCH"
    ;;
  "setup_firefly")
    setup_app "firefly" "$FIREFLY_REPO" "$FIREFLY_DOMAIN" "$FIREFLY_PORT" "$FIREFLY_SECRET" "$FIREFLY_BRANCH"
    ;;
  "destroy_dragonfly")
    destroy_app "dragonfly" "$DRAGONFLY_REPO" "$DRAGONFLY_DOMAIN" "$DRAGONFLY_PORT" "$DRAGONFLY_SECRET" "$DRAGONFLY_BRANCH"
    ;;
  "destroy_firefly")
    destroy_app "firefly" "$FIREFLY_REPO" "$FIREFLY_DOMAIN" "$FIREFLY_PORT" "$FIREFLY_SECRET" "$FIREFLY_BRANCH"
    ;;
  *)
    ;;
esac

echo "Operation completed successfully!"
