terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.43"  # Keep using 2.x series
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"  # This will still keep you within the 5.x range
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"   # Update if necessary
    }
  }
}


# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
