

We gitignore terraform state files (e.g terraform.tfstate).  Why? More info: https://stackoverflow.com/a/38748987


### Guide

#### Manual
Set the following environment variables

**For DigitalOcean to work with TF**
export DIGITALOCEAN_ACCESS_TOKEN=dop_v1_thisIsYourDigitalOceanAccessToken

**For TF**
LINUX_USER_DEVOPS_1A
LINUX_SSH_KEY_1A (this one uses quotations because it contains spaces)
SERVER_NAME_1A

**[Keep in Mind]**
👉 Linux/MacOS env vars must be prefixed with TF_VAR_ for tf to find them.

```bash
#Note that we prefix all TF Env Vars with TF_VAR_
export TF_VAR_LINUX_USER_DEVOPS_1A=yourUser_fromTF_config_file
export TF_VAR_LINUX_SSH_KEY_1A="ssh-ed25519 AAAA__yourSSH_Key___fromTF_config_file__6U13+ your@email.com"
export TF_VAR_SERVER_NAME_1A=yourServerName_fromTF_config_file
```

**[Keep in Mind]**
👉 You may need to add your ssh key to the IdentiyFile section of your `~/.ssh/config` file as shown below.  A problem I was running into was that I did not set a password on my ssh key during the ssh-keygen step.  Then I would attempt to ssh into a newly tf -created server and I would be prompted for my password.  Then I realized I was missing an entry in the ssh config file.  Once I added it, things worked as expected.


```bash
# open ~/.ssh/config with your IDE
code  ~/.ssh/config

# Add name of your ssh key to it, like this:
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/yourKeyFilename
```

#### 1password

### Editing guide -- questions, todo, etc.

- How can I pass env vars into terraform script? It would be great to:
  - run a CLI command to push keys/pws from 1pass into env vars


Terraform environment variables 
https://spacelift.io/blog/how-to-use-terraform-variables
"To do so, simply set the environment variable in the format TF_VAR_<variable name> . The variable name part of the format is the same as the variables declared in the variables.tf file"

### ___GUIDE___