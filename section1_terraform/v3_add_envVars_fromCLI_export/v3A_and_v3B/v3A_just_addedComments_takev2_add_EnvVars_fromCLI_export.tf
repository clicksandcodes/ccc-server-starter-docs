# In this example, we take v2.
# Discussion Version.

# Original source of template:
# https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021

# We tweak the original template, add in some stuff (docker, github), and then we edit it to make it more dynamic: to allow us to set env vars (via CLI export statements) so that they are picked up by Terraform.
# Note that, in this example V3, we keep it simple: We will not use a secrets manager tool in this version.

# Eventually, we will combine this with the next technique: Setting env vars by running a command to export the env vars from a secret manager (Initially, 1password (v4A).  Later, (v4B)when we place this into production, we'll use github secrets during github actions CICD process)

### Read the above URL article ("Original source of template") before working with this, to make sure you don't miss anything--
# For example, you'll need to run this export command:
#  export DIGITALOCEAN_ACCESS_TOKEN=YOUR_DO_TOKEN_HERE

### The below code has been modified to add in a few things.
# Note1: Suboptimal things
# - Note that the below code is not optimal-- we should be passing in various things as variables so that this code can be used more dynamically.
# Note 2: Things added in, compared to original
# - See section: # install docker-compose
# - See section: # install gh for github auth via CLI

####### List of Env Vars we will be setting.
# As we saw in "section0_learning_examples/ basic_ex2_envVar_fromOS_CLIExport.tf", all variables will be defined as terraform varibles.  But to keep it simple, we will also make a simple list here.

# Note: We could add other things as env vars if we chose to, such as the size of our droplet (AKA server).  But for this guide we are only going to focus on setting secrets as env vars, such as API keys, passwords, username, servername, etc.  We protect names of things so that they're more difficult to target.

## Env Vars List section 1: General env vars (Non-terraform-related)
# - DIGITALOCEAN_ACCESS_TOKEN

## Env Vars List section 2: Env vars for Terraform
# We'll document them as before and after-- first as they currently appear, plus what we will change them to in order to make them dynamic, env vars fed from our OS "export key=value" statements.
# - Droplet name.  Below, shown as: ubuntu-22-terraform
#   resource "digitalocean_droplet" "droplet" {
#    image     = "ubuntu-22-04-x64"
#    name      = "ubuntu-22-terraform"
#   }

# After that, the next section is "#cloud-config", which is nested in the resource definition.  Uh oh! Not so simple to dynamically insert, compared to just having a variable.
# So, How do we approach this?
# Perhaps we will need to extract that section and insert it dynamically via a shell file...
# Or perhaps there some way we can insert the env vars.

# Or, perhaps we can use the technique shown here-- by extracting the "#cloud-config" section into its related cloud-init yaml code
# https://developer.hashicorp.com/terraform/tutorials/provision/cloud-init

# Yaml is a good idea because Yaml can be dynamically edited with tools like yq (https://mikefarah.gitbook.io/yq/)

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
    micro     = "s-2vcpu-2gb"
    small     = "s-2vcpu-4gb"
    medium    = "s-4vcpu-8gb"
    large     = "s-6vcpu-16gb"
    x-large   = "s-8vcpu-32gb"
    xx-large  = "s-16vcpu-64gb"
    xxx-large = "s-24vcpu-128gb"
    maximum   = "s-32vcpu-192gb"
  }
  // Map of regions
  regions = {
    new_york_1    = "nyc1"
    new_york_3    = "nyc3"
    san_francisco = "sfo3"
    amsterdam     = "ams3"
    singapore     = "sgp1"
    london        = "lon1"
    frankfurt     = "fra1"
    toronto       = "tor1"
    india         = "blr1"
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
    # ~/.ssh/id_ed25519__14inchMBP_7_15_23
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