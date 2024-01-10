Source of project code:
https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021

## Be sure to check out the README files which appear in each file section.


### Things to keep in mind regarding Terraform projects.

- If you are using cloud-init code, the cloud-init section must have this shebang at the top-- whether it's in a .tf file, or if it's in a yaml file:  #cloud-config
- All env vars which you want tf to recognize must begin with TF_VAR_
- Don't forget to add these to your .gitignore
  - **/*.tfstate
  - **/*.tfstate.backup
  - **/.terraform

### 1Password secret extraction

```bash
# Recall that we must prefix env vars with TF_VAR_ to have them picked up by Terraform.
# So, this should work for you:
# bash / CLI
export TF_VAR_LINUX_USER_DEVOPS_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_USER_DEVOPS_1A) &&
export TF_VAR_LINUX_SSH_KEY_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_SSH_KEY_1A) &&
export TF_VAR_LINUX_SERVER_NAME_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_SERVER_NAME_1A)

```

```terraform
# In your tf file, you must then declare the variables, including defaults, in this sort of way:
variable "LINUX_SERVER_NAME_1A" {
  type = string
  description = "environment variable for devops user"
  default = "blahServerName"
}

# You can then reference the variables in tf files like this:
something = "${var.LINUX_SERVER_NAME_1A}"

# or feed them into a yaml file from the tf file, like this:
data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/v2_changedToEnvVars.yaml", 
    {
      LINUX_USER_DEVOPS_1A = "${var.LINUX_USER_DEVOPS_1A}",
      LINUX_SSH_KEY_1A = "${var.LINUX_SSH_KEY_1A}",
    })
}

# in the yaml file, they're then referenced like this-- like a linux env var item:
primary_group: ${LINUX_USER_DEVOPS_1A}

```

So, now that we can run our terraform + yaml combination from our CLI, using secrets we dynamically extract from 1password, we can apply the same process via Github Actions CICD.

Prior to that though, We need to do & decide a few things

- Make a copy of the TF & yaml files we intend to use
- Setup & test out the github action env var references
- Run the process based on a branch name, such as "release_createNewServer"


### Github Actions CICD - Action Setup
- Github Actions CICD spins up a temporary linux server
- That linux server, which has access to our repo's github secrets then inserts the secrets' values into the tf script, and it boots up our server for us.
- Then, that temporary linux server can move to the next step: creating our nginx-certbot docker container, to allow encrypted web traffic to flow into our servers.  That process will be setup as follows:

- a nginx main conf file (also in the docker container)
- a nginx sub-conf file for each project, for example:
  - the basic http test connection
    - a server block plus an json file
    - a CICD process which attempts a "health check" to ensure the json file can be reached
  - the https test connection.
    - Once our automatic verification checks that http traffic is flowing, then we repeat the above, except via https:
    -  a server block plus an json file.  Checked for connectivity with a "health check"
  - now that we verify http & https are working, we can continue on:
  - a serverblock for every subsequent app or website we add to the server.

1. First, a basic http server will be setup and tested for traffic.  It will fit into our overall nginx setup because we'll have a main nginx conf file, and we'll have sub-conf files.  The http server will be its own sub-conf file.