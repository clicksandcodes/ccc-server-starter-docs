# File: v3C_adding_cloud_config_section.tf
# Experimental version...
# The things we will consider regarding this example:

# 1. The change we make: Extract the "#cloud-config" section into a cloud-init section.
# Note: we have not made all the necessary changes.
# In an upcoming version, we will update the remaining things:
#     resource "digitalocean_droplet" "droplet" {
#       image     = "ubuntu-22-04-x64"
# -->   name      = "ubuntu-22-terraform"
#       ...
#     }

# Steps:
# 1. We move the #cloud-config section into a yaml file, with some v1_someName.yml sort of name, because after that we'll do a v2-- which is where we actually edit the code (such as to provide some env vars... or set it up such that the entire file becomes an env var... or perhaps we can, into it, append or insert the section which is an env var... dynamically)
# file name: v1_initialCloudConfig_from_v3C.yaml

# 2. We reference that file from the tf code.
# We add in the "data" resource.

# ___Template example (src: https://developer.hashicorp.com/terraform/tutorials/provision/cloud-init#add-the-cloud-init-script-to-the-terraform-configuration)
# 
# data "template_file" "user_data" {
  # template = file("../scripts/add-ssh-web-app.yaml")
# }

# ___Our version: 
# Note: You must keep this as "data "template_file" " because data is a resource type, and template_file is also the name of a sub-resource type".  Previously I tried to use "our_template_file" because I am still a bit new to terraform.
# There was an error:  Error: Failed to query available provider packages
# │
# │ Could not retrieve the list of available versions for provider hashicorp/our: provider registry
# │ registry.terraform.io does not have a provider named registry.terraform.io/hashicorp/our
# 
# "our" i.e. the beginning of "our_template_file" which terraform could not find as it doesnt exist as a sub-resource type (when I say 'sub-resource type' -- that's my language, at present I don't know exactly how terraform refers to that section of the resource definition in the code)

# So, after fixing that... I get this error:

# │ Error: Incompatible provider version
# │ 
# │ Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package available for your current
# │ platform, darwin_arm64.
# │ 
# │ Provider releases are separate from Terraform CLI releases, so not all providers are available for all
# │ platforms. Other versions of this provider may have different platforms supported.
# ╵

# Possible fix: https://discuss.hashicorp.com/t/template-v2-2-0-does-not-have-a-package-available-mac-m1/35099/4
# data "template_file" "user_data" {
  # template = file("./yamlScripts/v1_initialCloudConfig_from_v3C.yaml")
# }

# " user_data = <<EOF "
# becomes:
# user_data = data.template_file.user_data.rendered



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

data "template_file" "my_example_user_data" {
  template = file("./yamlScripts/v1_initialCloudConfig_from_v3C.yaml")
}

resource "digitalocean_droplet" "droplet" {
  image     = "ubuntu-22-04-x64"
  # appending -test-12-03-23 to differentiate from other server
  name      = "ubuntu-22-terraform-test-12-03-23"
  region    = local.regions.san_francisco
  size      = local.sizes.nano
  tags      = ["terraform", "docker"]
  user_data = data.template_file.my_example_user_data.rendered
}

# Output.  This script will output the ip_address of the droplet created.

output "ip_address" {
  value       = digitalocean_droplet.droplet.ipv4_address
  description = "The public IP address of your droplet."
}