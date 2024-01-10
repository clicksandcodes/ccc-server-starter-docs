# In this example, we will attempt to access within Tf the actual env vars we intend to use


#...... actually... nevermind.
# I was having issues with the env var exports because TF wasn't picking them up.  Then I read through the comments of the file basic_ex2_envVar_fromOS_CLIExport.tf
# and I saw the export statements must be prefixed with TF_VAR_
# Which I failed to do...
# So now, to try again, the right way.