
# Source of the below example: https://stackoverflow.com/a/68010624

# This is just an example to illustrate a technique of passing a variable into the terraform environment.
# In this case, when run, this script will ask you to enter a number.  The number is supposed to represent a quantity of virtual machines.  But it's just to illustrate how to pass data into the terraform apply process (by data, in this case, I mean an environment variable).


terraform {
  required_version = ">= 1.0.0"
}

variable "example_of_a_variable" {
    description = "How many VMs do you want to start with (number)? default=1 max=5"
    type = number
}

output "example_to_print" {
  value = "${var.example_of_a_variable > 2 && var.example_of_a_variable < 6 ? var.example_of_a_variable : 2}"
}