Invoke-Expression (& { (zoxide init powershell | Out-String) })
# i can't be sure that there will be these instalation in any new machine, so comment it for now
#function Set-Kickstart {
#    [Environment]::SetEnvironmentVariable('NVIM_APPNAME', 'nvim')
#	nvim
#}

#function Set-Lazy {
#    [Environment]::SetEnvironmentVariable('NVIM_APPNAME', 'lazy')
#	nvim
#}

#Set-Alias -Name kickstart -Value Set-Kickstart
#Set-Alias -Name lazy -Value Set-Lazy

Set-Alias -Name v -Value nvim
