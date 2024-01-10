# TF Env Vars

#### Resources

- [How to Use Terraform Variables (Locals, Input, Output, Environment)](https://spacelift.io/blog/how-to-use-terraform-variables#local-variables)
  - Focus in on this section : https://spacelift.io/blog/how-to-use-terraform-variables#environment-variables

### Discussion on how to use environment variables with Terraform

Two decent options:
- Feed env vars via: (there are other ways of course)
  1. 1pass -> environment (e.g. export TF_VAR_someKey=someValue) -> terraform env var, where they are picked up and used by terraform
    - In this example, we could use CICD if we simply replace the 1pass step with a CICD CLI command which extracts the values from CICD secret storage (similar to extracting them from 1pass secret storage)
  2. 1pass -> some CLI Command to write them to .tfvars file -> where they are picked up and used by terraform
    - In this example, we would want to make sure teh .tfvars file gets encrypted by MOPS or a similar file encryption tool

( More info: https://www.youtube.com/watch?v=BeWIVXqCrH0 )
We'll go with #1 above.  I find it a bit easier to work with.  However it might be safer to go with #2 in large and/or commercialized production systems.
