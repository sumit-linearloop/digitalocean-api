name: CI/CD dev Pipeline

on:
  workflow_dispatch:  # Enables manual trigger

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3  # Updated to v3 for latest features

      - name: Set up SSH
        run: |
          echo "Setting up SSH..."
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          touch ~/.ssh/known_hosts
          ssh-keyscan -H 128.199.28.236 | sort -u >> ~/.ssh/known_hosts
          echo "SSH setup completed."

      - name: Configure SSH key and disable strict host checking
        run: |
          echo "Configuring SSH..."
          {
            echo "Host 128.199.28.236"
            echo "  StrictHostKeyChecking no"
            echo "  UserKnownHostsFile=/dev/null"
          } >> ~/.ssh/config
          chmod 600 ~/.ssh/config
          echo "SSH configuration completed."
      
      - name: Test SSH Connection
        run: |
          echo "Testing SSH connection..."
          ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@128.199.28.236 "echo 'SSH connection successful'" || { echo "SSH connection to remote server failed"; exit 1; }
      
      - name: Deploy Application
        run: |
          echo "Starting deployment..."
          ssh -i ~/.ssh/id_rsa root@128.199.28.236 "chmod +x /root/dev.sh && /root/dev.sh" || { echo 'Deployment failed'; exit 1; }
          echo "Deployment completed successfully."
