# In this example, we will set an env var via an export command in our CLI.  From there, Terraform will pick up the env var and pass it into its "terraform apply" process.

# Things we need:
# 1. a default definition of the variable
# 2. to run a command to set the env var within our operating system, in mac we use "export key=value"
# 3. test it out, just in case, by using " print ${key} " (no quotations.  and you should see the value in the CLI)
# 4. Now you are ready to run the tf file:
# terraform init
# terraform plan
# terraform apply

terraform {
  required_version = ">= 1.0.0"
}

# Step 1
variable "example_env_var" {
  type = string
  description = "environment variable example"
  default = "blah"
}

# Step 2 & 3
# on MacOS, run this in your CLI:
# export TF_VAR_example_env_var=Hello123
# note that that value is simply: TF_VAR_ with our variable name appended.  To be picked up by tf, you must set your OS env var's key such that it begins with TF_VAR_
# test it out by running in your CLI: print ${TF_VAR_example_env_var}


# And now this should be output in terminal when  you run this current tf file.
# note the value-- it's the key of the env var we set, minus TF_VAR_
# note that it's the same as what is defined in the default var:  
#   " variable "example_env_var" "
# note that when we refer to the env var, we must precede its key with "var."

output "example_print_envVar_via_terraformApply" {
  value = "${var.example_env_var}"
}

# So, now that we understand how to access Env Vars from our OS, that lets us do the following:

# Run a CLI command to set multiple secrets into our OS Env Vars
# Have those Secret items inserted from our OS Env Vars inserted into our Terraform command, when we run terraform apply.
