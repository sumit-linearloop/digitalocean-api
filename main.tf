resource "digitalocean_ssh_key" "existing" {
  name       = "sumit-key"              # Name for the SSH key in DigitalOcean
  public_key = var.ssh_public_key       # Use the ssh_public_key variable for the public key
}

resource "digitalocean_droplet" "web_server" {
  image    = "ubuntu-24-04-x64"
  name     = "sumit-1"
  region   = "blr1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.existing.fingerprint]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_private_key
    host        = self.ipv4_address
  }

  provisioner "file" {
    source      = "${path.module}/initial_setup.sh"
    destination = "/tmp/initial_setup.sh"
  }



  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/initial_setup.sh",
      "export SSH_PRIVATE_KEY='${var.ssh_private_key}'",
      "export NODE_VERSION='${var.node_version}'",
      "export AWS_ACCESS_KEY='${var.aws_access_key}'",
      "export AWS_SECRET_KEY='${var.aws_secret_key}'",
      "export AWS_REGION='${var.aws_region}'",
      "bash /tmp/initial_setup.sh"
    ]
  }
}
