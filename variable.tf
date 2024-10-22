variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

variable "droplet_image" {
  description = "Droplet image to use"
  type        = string
  default     = "ubuntu-20-04-x64"
}

variable "droplet_name" {
  description = "Name of the droplet"
  type        = string
  default     = "web-server"
}

variable "droplet_region" {
  description = "Region for the droplet"
  type        = string
  default     = "nyc3"
}

variable "droplet_size" {
  description = "Size of the droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}


# variable "github_repo" {
#   description = "GitHub repository URL"
#   type        = string
# }

variable "node_version" {
  description = "Node.js version to install"
  type        = string
}

variable "dragonfly_repo" {
  description = "GitHub repository URL for Dragonfly"
  type        = string
}

variable "firefly_repo" {
  description = "GitHub repository URL for Firefly"
  type        = string
}
variable "app_action" {
  description = "Action to perform on the app (setup_dragonfly, setup_firefly, destroy_dragonfly, destroy_firefly)"
  type        = string
  default     = ""
}

variable "firefly_port" {
    description = "port for firefly application"
    type = number
}

variable "dragonfly_port" {
    description = "port for dragonfly application"
    type = number
}

variable "dragonfly_domain" {
    description = "Dragonfly Domain"
    type = string  
}

variable "firefly_domain" {
    description = "Firefly Domain"
    type = string
}

variable "firefly_secret" {
    description = "Secret name for Firefly"
}

variable "dragonfly_secret" {
    description = "Secret name for Dragonfly"
}

variable "firefly_branch" {
    description = "Branch for Firefly"
}

variable "dragonfly_branch" {
    description = "Branch for Dragon"
}

# Variable declarations
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}


variable "github_secret" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for DigitalOcean"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key content"
  type        = string
}

