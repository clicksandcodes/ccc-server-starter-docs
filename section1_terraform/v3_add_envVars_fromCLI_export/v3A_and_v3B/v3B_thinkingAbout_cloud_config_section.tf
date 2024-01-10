# File: v3B_fixing_cloud_config_section.tf
# Discussion version

# The things we will consider regarding this example:

# 1. A change we make: Reduce the local variables down to the ones we use, for visual brevity of the file.
# 2. The thing we think about: How will we extract the "#cloud-config" section into a cloud-init section?

# Re: #2.  How?
# Well, let's look at this documentation:
# https://developer.hashicorp.com/terraform/tutorials/provision/cloud-init
# And let's notice a few things"
# - The cloud init code is in a separate yaml file.
# - The yaml file is given a terraform resource type of "data", with the name "template_file".  Now that we see that, we can ctrl-f for "template_file" to see how it is referenced... and we see:
# user_data = data.template_file.user_data.rendered
# And we compare that with how "user_data" appears in the below file.
# In this current file, it appears: user_data = <<EOF ...cloud config code (and it ends with "EOF").  EOF stands for "end of file".  So basically, user_data holds data which can be a "file" section (i.e. it literally says EOF ("End Of File") as a hint... within the code below).  So that's pretty simple-- this shows that we reference a separate file.

# Well... Our goal is to NOT store our env vars in a file-- but to feed them straight from CLI Env vars.  But that's ok! Because we can likely set a whole YAML file within our CLI Env vars.  Perhaps not the best practice, but if it works, it works.

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
  sizes = {
    nano      = "s-1vcpu-1gb"
  }
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