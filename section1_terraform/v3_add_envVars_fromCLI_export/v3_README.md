This readme is to keep comments from this section in one place.

## Version 3: Taking v2 and figuring out how we will make it dynamic.

Version
In this example, we take v2.

Original source of template:
https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021

We tweak the original template, add in some stuff (docker, github), and then we edit it to make it more dynamic: to allow us to set env vars (via CLI export statements) so that they are picked up by Terraform.
Note that, in this example V3, we keep it simple: We will not use a secrets manager tool in this version.

Eventually, we will combine this with the next technique: Setting env vars by running a command to export the env vars from a secret manager (Initially, 1password (v4A).  Later, (v4B)when we place this into production, we'll use github secrets during github actions CICD process)

Read the above URL article ("Original source of template") before working with this, to make sure you don't miss anything--

For example, you'll need to run this export command:
 export DIGITALOCEAN_ACCESS_TOKEN=YOUR_DO_TOKEN_HERE

The below code has been modified to add in a few things.
Note1: Suboptimal things
- Note that the below code is not optimal-- we should be passing in various things as variables so that this code can be used more dynamically.

Note 2: Things added in, compared to original
- See section: # install docker-compose
- See section: # install gh for github auth via CLI

#### List of Env Vars we will be setting.

As we saw in "section0_learning_examples/ basic_ex2_envVar_fromOS_CLIExport.tf", all variables will be defined as terraform varibles.  But to keep it simple, we will also make a simple list here.

Note: We could add other things as env vars if we chose to, such as the size of our droplet (AKA server).  But for this guide we are only going to focus on setting secrets as env vars, such as API keys, passwords, username, servername, etc.  We protect names of things so that they're more difficult to target.

##### Env Vars List section 1: General env vars (Non-terraform-related)
- DIGITALOCEAN_ACCESS_TOKEN

##### Env Vars List section 2: Env vars for Terraform
We'll document them as before and after-- first as they currently appear, plus what we will change them to in order to make them dynamic, env vars fed from our OS "export key=value" statements.
- Droplet name.  Below, shown as: ubuntu-22-terraform
  resource "digitalocean_droplet" "droplet" {
   image     = "ubuntu-22-04-x64"
   name      = "ubuntu-22-terraform"
  }

After that, the next section is "#cloud-config", which is nested in the resource definition.  Uh oh! Not so simple to dynamically insert, compared to just having a variable.
So, How do we approach this?
Perhaps we will need to extract that section and insert it dynamically via a shell file...
Or perhaps there some way we can insert the env vars.

Or, perhaps we can use the technique shown here-- by extracting the "#cloud-config" section into its related cloud-init yaml code
https://developer.hashicorp.com/terraform/tutorials/provision/cloud-init

Yaml is a good idea because Yaml can be dynamically edited with tools like yq (https://mikefarah.gitbook.io/yq/)


__________
File: v3C_adding_cloud_config_section.tf
Experimental version...
The things we will consider regarding this example:

1. A change we make: Reduce the local variables down to the ones we use, for visual brevity of the file.
2. The thing we think about: How will we extract the "#cloud-config" section into a cloud-init section?

Re: #2.  How?
Well, let's look at this documentation:
https://developer.hashicorp.com/terraform/tutorials/provision/cloud-init
And let's notice a few things"
- The cloud init code is in a separate yaml file.
- The yaml file is given a terraform resource type of "data", with the name "template_file".  Now that we see that, we can ctrl-f for "template_file" to see how it is referenced... and we see:
user_data = data.template_file.user_data.rendered
And we compare that with how "user_data" appears in the below file.
In this current file, it appears: user_data = `<<EOF ...cloud config code` (and it ends with "EOF").  EOF stands for "end of file".  So basically, user_data holds data which can be a "file" section (i.e. it literally says EOF ("End Of File") as a hint... within the code below).  So that's pretty simple-- this shows that we reference a separate file.

Well... Our goal is to NOT store our env vars in a file-- but to feed them straight from CLI Env vars.  But that's ok! Because we can likely set a whole YAML file within our CLI Env vars.  Perhaps not the best practice, but if it works, it works.



Steps:
1. We move the #cloud-config section into a yaml file, with some v1_someName.yml sort of name, because after that we'll do a v2-- which is where we actually edit the code (such as to provide some env vars... or set it up such that the entire file becomes an env var... or perhaps we can, into it, append or insert the section which is an env var... dynamically)
file name: v1_initialCloudConfig_from_v3C.yaml

2. We reference that file from the tf code.
We add in the "data" resource.

___Template example (src: https://developer.hashicorp.com/terraform/tutorials/provision/cloud-init#add-the-cloud-init-script-to-the-terraform-configuration)

data "template_file" "user_data" {
    template = file("../scripts/add-ssh-web-app.yaml")
}

...Which becomes (in our version):

data "template_file" "user_data" {
    template = file("./yamlScripts/v1_initialCloudConfig_from_v3C.yaml")
  }


" user_data = <<EOF "
becomes:
user_data = data.template_file.user_data.rendered

IDEALLY-- But not yet! Because we are experiencing some errors.

Note: we are on a M2 Macbook pro. OS Sonoma 14.1 (23B74)

Note: You must keep this as "data "template_file" " because "data" is a resource type, and "template_file" is also the name of a sub-resource type".  Previously I tried to use "our_template_file" because I am still a bit new to terraform.
There was an error:  Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider hashicorp/our: provider registry
│ registry.terraform.io does not have a provider named registry.terraform.io/hashicorp/our

"our" i.e. the beginning of "our_template_file" which terraform could not find as it doesnt exist as a sub-resource type (when I say 'sub-resource type' -- that's my language, at present I don't know exactly how terraform refers to that section of the resource definition in the code)

So, after fixing that... I get this error:

│ Error: Incompatible provider version
│ 
│ Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package available for your current
│ platform, darwin_arm64.
│ 
│ Provider releases are separate from Terraform CLI releases, so not all providers are available for all
│ platforms. Other versions of this provider may have different platforms supported.
╵

Possible fix: https://discuss.hashicorp.com/t/template-v2-2-0-does-not-have-a-package-available-mac-m1/35099/5

___Fix attempts___
trying: change template('filepath') to: templatefile('filepath') 
   ...nope, same error as before.

trying:
(https://discuss.hashicorp.com/t/template-v2-2-0-does-not-have-a-package-available-mac-m1/35099/7)
brew install kreuzwerker/taps/m1-terraform-provider-helper
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
...those commands worked without issue...
now to try running `terraform init` again.
**Yep! It worked!**

```terraform
terraform apply
╷
│ Error: Not enough function arguments
│ 
│   on v3C_adding_cloud_config_section.tf line 81, in data "template_file" "my_example_user_data":
│   81:   template = templatefile("./yamlScripts/v1_initialCloudConfig_from_v3C.yaml")
│     ├────────────────
│     │ while calling templatefile(path, vars)
│ 
│ Function "templatefile" expects 2 argument(s). Missing value for "vars".
```

oops... I still had this: (templatefile -- i should have reverted it back to just 'file')
template = file("./yamlScripts/v1_initialCloudConfig_from_v3C.yaml")

Failing that, i'll try templatefile and see what the error menat by "expects 2 argument(s). Missing value for "vars"."

...ok, had an error because I forgot to `export DIGITALOCEAN_ACCESS_TOKEN=myToken`

...and... looks to be working
Ok, it worked.

Yaml makes it easy to insert variables from CLI Env vars-- They are accessed the same way as in Linux-- ${someEnvVar}

So, ultimately we'll do this:

<1pass CLI commands to extract & set env vars> | <run terraform commands>

________________

### File: v3D_adding_cloud_config_section.tf

After adding Env Vars into the yaml file, we had to make a change to v3C.

we changed file() to templatefile().  templatefile() lets you pass in a 2nd argument, which are the env vars, whereas file only lets you pass in one argument-- the filepath.

data "template_file" "my_example_user_data" {
  template = file("./yamlScripts/v2_changedToEnvVars.yaml")
}

Became:
data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/v2_changedToEnvVars.yaml",
    {
      LINUX_USER_DEVOPS_1A = var.LINUX_USER_DEVOPS_1A,
      LINUX_SSH_KEY_1A = var.LINUX_SSH_KEY_1A
    })
}
And, of course, we also set those two items as terraform variables within the terraform file.

...So, now that works.

The only thing left to do is to set the env vars by exporting them from a password manager.

Locally: 1password.
Remotely (CICD): github actions secrets.

....

I was unable to use the 1pass secret reference code for the servername.
For username it worked.  But the ssh key required a pw-- and I set it without a password.
So, 2/3 fail on that.
See solution below "[Problem - missing ssh key reference in ssh config]"

I'll have to use regular ol' CLI env vars

We'll try this then:

```bash

export TESTITEM=$(op item get "ClicksAndCodes 1A server" --fields label=testItem)

export TESTITEM=$(op item get "ClicksAndCodes 1A server" --fields label=testItem)

LINUX_USER_DEVOPS_1A
LINUX_SSH_KEY_1A
LINUX_SERVER_NAME_1A

export LINUX_USER_DEVOPS_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_USER_DEVOPS_1A) &&
export LINUX_SSH_KEY_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_SSH_KEY_1A) &&
export LINUX_SERVER_NAME_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_SERVER_NAME_1A)

## WRONG!!!  We forgot TF_VAR_ !!!!!!!! That's why TF didn't pick them up.

export TF_VAR_LINUX_USER_DEVOPS_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_USER_DEVOPS_1A) &&
export TF_VAR_LINUX_SSH_KEY_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_SSH_KEY_1A) &&
export TF_VAR_LINUX_SERVER_NAME_1A=$(op item get "ClicksAndCodes 1A server" --fields label=LINUX_SERVER_NAME_1A)

```

...So... the servername went through.  The droplet was made with the name I fed into env var.
However, I am unable to login w/ `ssh yourChosenUserNameForLinuxServerLogin@IPADDRESS` -- it keeps asking for password

... docs on templatefile() : https://developer.hashicorp.com/terraform/language/functions/templatefile

[Problem]
I forgot to feed the env vars into the template file in this style:
"${var.example_env_var}"

I have this:
data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/v2_changedToEnvVars.yaml", 
    {
      LINUX_USER_DEVOPS_1A = var.LINUX_USER_DEVOPS_1A,
      LINUX_SSH_KEY_1A = var.LINUX_SSH_KEY_1A,
    })
}

[Solution]
But it should be this:
data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/v2_changedToEnvVars.yaml",
    {
      LINUX_USER_DEVOPS_1A = "${var.LINUX_USER_DEVOPS_1A}",
      LINUX_SSH_KEY_1A = "${var.LINUX_SSH_KEY_1A}",
    })
}


12/6/23
[Problem - missing shebang]
Ah hah... Yeah there's a problem in my dynamic yaml attempt.  None of the packages got installed

...the problem: I didnt add the shebang "#cloud-config" to the top of yaml.
[Solution]

[Problem - missing ssh key reference in ssh config]
Also, you may run into a problem where, when you `ssh username@ip` you are be prompted with a password even if you did not set one

[Solution]:
```bash
# open ~/.ssh/config with your IDE
code  ~/.ssh/config

# Add name of your ssh key to it, like this:
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/yourKeyFilename
```