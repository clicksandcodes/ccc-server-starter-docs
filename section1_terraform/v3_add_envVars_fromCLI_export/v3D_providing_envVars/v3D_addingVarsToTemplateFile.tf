# File: v3D_adding_cloud_config_section.tf

# After adding Env Vars into the yaml file, we had to make a change to v3C.

# we changed file() to templatefile().  templatefile() lets you pass in a 2nd argument, which are the env vars, whereas file only lets you pass in one argument-- the filepath.

# data "template_file" "my_example_user_data" {
#   template = file("./yamlScripts/v2_changedToEnvVars.yaml")
# }

# Became:
# data "template_file" "my_example_user_data" {
#   template = templatefile("./yamlScripts/v2_changedToEnvVars.yaml",
#     {
#       LINUX_USER_DEVOPS_1A = var.LINUX_USER_DEVOPS_1A,
#       LINUX_SSH_KEY_1A = var.LINUX_SSH_KEY_1A
#     })
# }
# And, of course, we also set those two items as terraform variables within the file.

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

# the SERVER_NAME is not as important to set via env var... but we will go ahead and do it
variable "LINUX_SERVER_NAME_1A" {
  type = string
  description = "environment variable for devops user"
  default = "blahServerName"
}

variable "LINUX_USER_DEVOPS_1A" {
  type = string
  description = "environment variable for devops user"
  default = "blahLinxUser"
}

variable "LINUX_SSH_KEY_1A" {
  type = string
  description = "environment variable for devops ssh key"
  default = "blahSshKey"
}

data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/v2_changedToEnvVars.yaml", 
    {
      LINUX_USER_DEVOPS_1A = "${var.LINUX_USER_DEVOPS_1A}",
      LINUX_SSH_KEY_1A = "${var.LINUX_SSH_KEY_1A}",
    })
}

resource "digitalocean_droplet" "droplet" {
  image     = "ubuntu-22-04-x64"
  name      = "${var.LINUX_SERVER_NAME_1A}"
  region    = local.regions.san_francisco
  size      = local.sizes.nano
  tags      = ["terraform", "docker"]
  user_data = data.template_file.my_example_user_data.rendered
}

output "ip_address" {
  value       = digitalocean_droplet.droplet.ipv4_address
  description = "The public IP address of your droplet."
}


# If you want to make sure the yaml file was properly filled with env vars, you can uncomment this output statement and terraform will show the env vars in situ
# output "template_file_contents" {
#   value = data.template_file.my_example_user_data.rendered
# }

output "LINUX_SERVER_NAME_1A" {
  value = "${var.LINUX_SERVER_NAME_1A}"
}

output "LINUX_USER_DEVOPS_1A" {
  value = "${var.LINUX_USER_DEVOPS_1A}"
}

output "LINUX_SSH_KEY_1A" {
  value = "${var.LINUX_SSH_KEY_1A}"
}