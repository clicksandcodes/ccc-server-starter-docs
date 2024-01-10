# This is a TF Template to create a Linux server on DigitalOcean, in an automated way with Terraform.

# Original source of template:
# https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021

### Read the above URL article before working with this, to make sure you don't miss anything--
# For example, you'll need to run this export command:
#  export DIGITALOCEAN_ACCESS_TOKEN=YOUR_DO_TOKEN_HERE

### The below code has been modified to add in a few things.
# Note1: Suboptimal things
# - Note that the below code is not optimal-- we should be passing in various things as variables so that this code can be used more dynamically.
# Note 2: Things added in, compared to original
# - See section: # install docker-compose
# - See section: # install gh for github auth via CLI



terraform {
  required_version = ">= 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

locals {
  // Map of pre-named sizes to look up from
  sizes = {
    nano      = "s-1vcpu-1gb"
  }
  // Map of regions
  regions = {
    san_francisco = "sfo3"
  }
}

provider "digitalocean" {}

resource "digitalocean_droplet" "droplet" {
  image     = "ubuntu-22-04-x64"
  name      = "ubuntu-22-terraform"
  region    = local.regions.san_francisco
  size      = local.sizes.nano
  tags      = ["terraform", "docker"]
  user_data = <<EOF
  
#cloud-config
groups:
  - ubuntu: [root,sys]
# Add users to the system. Users are added after groups are added.
users:
  - default
  - name: yourChosenUserNameForLinuxServerLogin
    gecos: yourChosenUserNameForLinuxServerLogin
    shell: /bin/bash
    primary_group: yourChosenUserNameForLinuxServerLogin
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, docker
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-ed25519 AAAA_yourSSH_key__6U13+ your@email.com
  
runcmd:
  - sudo apt-get -y update
  - sudo apt -y install apt-transport-https ca-certificates curl software-properties-common net-tools
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  - sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable"
  - sudo apt -y update
  - sudo apt-cache policy docker-ce && apt-get -y install docker-ce
  - sudo usermod -aG docker yourChosenUserNameForLinuxServerLogin
  # install docker-compose
  - sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  - sudo chmod +x /usr/local/bin/docker-compose
  # install gh for github auth via CLI
  - sudo apt -y install gh
EOF
}

# Output.  This script will output the ip_address of the droplet created.

output "ip_address" {
  value       = digitalocean_droplet.droplet.ipv4_address
  description = "The public IP address of your droplet."
}