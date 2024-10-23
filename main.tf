# Define SSH key resource
resource "digitalocean_ssh_key" "existing" {
  name       = "sumit-key"              # Name for the SSH key in DigitalOcean
  public_key = var.ssh_public_key       # Use the ssh_public_key variable for the public key
}

# Create a DigitalOcean Droplet
resource "digitalocean_droplet" "web_server" {
  image    = "ubuntu-24-04-x64"         # OS Image
  name     = "sumit-2"                  # Droplet name
  region   = "blr1"                     # Bangalore region
  size     = "s-1vcpu-1gb"              # Plan: 1 vCPU, 1GB RAM
  ssh_keys = [digitalocean_ssh_key.existing.fingerprint]

  # SSH connection configuration
  connection {
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_private_key
    host        = self.ipv4_address
  }

  # File provisioner to upload the initial setup script
  provisioner "file" {
    source      = "${path.module}/initial_setup.sh"  # Local script path
    destination = "/tmp/initial_setup.sh"            # Destination on droplet
  }

  # Remote-exec provisioner to execute the setup script and environment setup
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/initial_setup.sh",  # Make the script executable
      "export SSH_PRIVATE_KEY='${var.ssh_private_key}'",
      "export NODE_VERSION='${var.node_version}'",
      "export AWS_ACCESS_KEY='${var.aws_access_key}'",
      "export AWS_SECRET_KEY='${var.aws_secret_key}'",
      "export AWS_REGION='${var.aws_region}'",
      "bash /tmp/initial_setup.sh > /tmp/setup.log 2>&1 || " +
      "(echo 'Initial setup failed, see /tmp/setup.log for details' && exit 1)"
    ]
  }
}

# Output the droplet's public IP address
output "droplet_public_ip" {
  description = "The public IP address of the web server droplet"
  value       = digitalocean_droplet.web_server.ipv4_address
}

# Null resource for post-deployment tasks or notifications
resource "null_resource" "app_management" {
  depends_on = [digitalocean_droplet.web_server]

  provisioner "local-exec" {
    command = "echo 'Droplet is up and running at ${digitalocean_droplet.web_server.ipv4_address}'"
  }
}
