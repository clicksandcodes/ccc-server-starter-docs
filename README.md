
### Original resources-- the starting templates

These are the original resources I began with.  These are essentially the starting templates which I modified.

- Terraform template
  - "How to create DigitalOcean droplet using Terraform. A-Z guide." https://archive.is/sn6HO  (Paywalled source article: https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021 )

- nginx-certbot template
  - Project Article "Nginx and Let’s Encrypt with Docker in Less Than 5 Minutes: Getting Nginx to run with Let’s Encrypt in a docker-compose environment is trickier than you’d think …" https://archive.is/l03XA (Paywalled source article: https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71 )
  - Project Code https://github.com/wmnnd/nginx-certbot/tree/master



## This Version Works
Tested the tf & yaml file in dir: v3D_providing_envVars
and they work!

This kit contains a guide to how we developed the templates into files used to with Terraform to automatically bootstrap an Ubuntu server, and within it, to setup a Nginx + Certbot server to allow web traffic to flow in.

## Steps to get a new server running

1. Step1: Review the TERRAFORM_README.md file and follow the guide within it.  Once your linux server is online, you're ready to setup a system to allow traffic to flow in securely, shown in step2.
  
2. TODO Create: Step2: review the NGINX_README.md file and follow the guide within it


#### Software frameworks we will use

1. terraform (In the future, perhaps OpenTofu, depending on how its development goes).  For this guide, we use Terraform v1.5.7 .  At this version, they are virtually the same (they diverged at v1.5.6 but it is very unlikely any code we use will result in any differences).
  - Why use Terraform instead of OpenTofu? ["At this time, there is no difference between the Terraform and OpenTofu commands other than calling “tofu” rather than “terraform”. src: scalr.com blog post](https://www.scalr.com/blog/everything-you-need-to-know-about-opentofu)
  - What is OpenTofu and how does it relate to Terraform?
    - OpenTofu is the FOSS Fork of Terraform.  Many in the Terraform community are switching to OpenTofu, a fully FOSS fork of Terraform:
    - This thread shows most respondents are continuing to use Terraform (As of late 2023) https://www.reddit.com/r/devops/comments/16q9tu2/will_you_be_moving_from_terraform_to_opentofu/
    - This article promotes the switch to OpenTofu https://medium.com/@zoiwrites/terraform-is-dead-long-live-opentofu-bf4c73364050
    - https://opentofu.org/

> "Is Terraform still open source? No, Terraform will cease to be open source. Everything created before version 1.5.x stays open-source, but new versions of Terraform are placed under the BUSL license."
> https://spacelift.io/blog/what-is-opentofu#is-terraform-still-open-source

2. nginx
3. certbot + letsencrypt
4. linux & shell files
5. Docker & docker-compose.  We will use docker & docker-compose to keep separate & decoupled, the applications we build.
   
#### Tools needed:

- Computer.  "Duh" you say. :D
  - I use an Apple laptop, but Linux is also good. I prefer those two the most, because Linux servers have the most market share-- and you navigate them the same way you do an Apple OS or a Linux desktop OS.
  - If you use Windows, you may want to consider installing Linux Subsystem for Windows so you can have a similar-to-linux experience without necessarily having to install Linux (such as with VirtualBox (and even Vagrant if you want to automate that))
- A Terminal (aka CLI) app.  I like iterm2 + zsh
  - Why Zsh? Because it provides some nifty plugins.  See appendix.
- VS Code
  - VS Code extensions:
    - [YAML Linter by RedHat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml).  Helpful to make sure out YAML is syntactically correct.
- 1password or similar secure password management tool

# The Guide

Scroll back up to "Steps to get a new server running" and follow the instructions in the Readme files mentioned.




## Appendix

- Zsh - My favorite plugins:
  - [powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [auto-jump](https://github.com/wting/autojump)
  - [git](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh) -- automatically included in oh-my-zsh, in turn included with powerlevel10k.
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/tree/master)