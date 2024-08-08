Invoke-Expression (& { (zoxide init powershell | Out-String) })

# $Env:NVIM_APPNAME = 'kickstart'

function Set-Kickstart {
    [Environment]::SetEnvironmentVariable('NVIM_APPNAME', 'nvim')
	nvim
}

function Set-Lazy {
    [Environment]::SetEnvironmentVariable('NVIM_APPNAME', 'lazy')
	nvim
}

function Install-WinGetApp {
    param (
        [string]$PackageID
    )
    Write-Verbose -Message "Preparing to install $PackageID"
    # Added accept options based on this issue - https://github.com/microsoft/winget-cli/issues/1559
    #$listApp = winget list --exact -q $PackageID --accept-source-agreements
    #if (winget list --exact --id "$PackageID" --accept-source-agreements) {
    #    Write-Verbose -Message "Package $PackageID already installed! Skipping..."
    #} else {
    #    Write-Verbose -Message "Installing $Package"
    #    winget install --silent --id "$PackageID" --accept-source-agreements --accept-package-agreements
    #}
    Write-Verbose -Message "Installing $Package"
    winget install --silent --id "$PackageID" --accept-source-agreements --accept-package-agreements
}

Set-Alias -Name kickstart -Value Set-Kickstart
Set-Alias -Name lazy -Value Set-Lazy

Set-Alias -Name v -Value nvim
