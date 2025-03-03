#based on https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7

# Install Scoop, if not already installed
#$scoopInstalled = Get-Command "scoop"
if ( !(Get-Command -Name "scoop") ) {
    Write-Verbose -Message "Installing Scoop..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))
}

function Install-ScoopApp {
    param (
        [string]$Package
    )
    Write-Verbose -Message "Preparing to install $Package"
    if (! (scoop info $Package).Installed ) {
        Write-Verbose -Message "Installing $Package"
        scoop install $Package
    } else {
        Write-Verbose -Message "Package $Package already installed! Skipping..."
    }
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

# Configure ExecutionPolicy to Unrestricted for CurrentUser Scope
if ((Get-ExecutionPolicy -Scope CurrentUser) -notcontains "Unrestricted") {
    Write-Verbose -Message "Setting Execution Policy for Current User..."
    Start-Process -FilePath "PowerShell" -ArgumentList "Set-ExecutionPolicy","-Scope","CurrentUser","-ExecutionPolicy","Unrestricted","-Force" -Verb RunAs -Wait
    Write-Output "Restart/Re-Run script!!!"
    Start-Sleep -Seconds 10
    Break
}

Install-WinGetApp -PackageID "Git.Git"

## Add Buckets
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add java
scoop bucket add nirsoft
scoop bucket add foosel https://github.com/foosel/scoop-bucket

$WinGet = @(
    "Microsoft.DotNet.Runtime.3_1",
    "Microsoft.DotNet.Runtime.5",
    "Microsoft.DotNet.Runtime.6",
    "Microsoft.DotNet.Runtime.7",
    "Microsoft.DotNet.Runtime.7",
    "Microsoft.DotNet.Runtime.8",
    "Microsoft.DotNet.SDK.3_1",
    "Microsoft.DotNet.SDK.5",
    "Microsoft.DotNet.SDK.6",
    "Microsoft.DotNet.SDK.7",
    "Microsoft.DotNet.SDK.7",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.VCRedist.2015+.x64",
    "Python.Python.3.11",
    "wez.wezterm",
    "Google.Chrome",
    "cURL.cURL",
    "Docker.DockerDesktop",
    "dbeaver.dbeaver",
    "7zip.7zip",

    #"Valve.Steam",
    "Microsoft.PowerShell",
    "BurntSushi.ripgrep.MSVC",
    "LLVM.LLVM",
    "OpenJS.NodeJS",
    "MSYS2.MSYS2",
    "OpenJS.NodeJS",
    "ezwinports.make",
    "GnuWin32.Tar",
    "Discord.Discord"
    )
foreach ($item in $WinGet) {
    Install-WinGetApp -PackageID "$item"
}

$Scoop = @(
  "fzf",
  "neovim",
  "zoxide",
  "fd",
  "starship",
  "lazygit",
  "lazydocker",
  "nu",
  "7zip",
  "bat",
  "cmake",
  "dog",
  "eza",
  "gping",
  "ntop",
  "nmap",
  "luarocks",
  "lua",
  #"posh-git",
  "pueue",
  "procs",
  "yazi",
  "tokei",
  "jo",
  "jq",
  "gdb",
  "gcc"
)

foreach ($item in $Scoop) {
        Install-ScoopApp -Package "$item"
}

# Custom WinGet install for VSCode
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'

# Pin Google Chrome to Taskbar
Write-Verbose -Message "Pin Google Chrome to Taskbar..."
#Start-Process -FilePath "PowerShell" -ArgumentList "syspin","'$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk'","c:5386" -Wait -NoNewWindow

# Install Windows SubSystems for Linux
$wslInstalled = Get-Command "wsl" -CommandType Application -ErrorAction Ignore
if (!$wslInstalled) {
    Write-Verbose -Message "Installing Windows SubSystems for Linux..."
    Start-Process -FilePath "PowerShell" -ArgumentList "wsl","--install" -Verb RunAs -Wait -WindowStyle Hidden
}
Install-WinGetApp -PackageID Canonical.Ubuntu.2204

# Install my PowerShell dot files
if (!(Test-Path -Path "$Env:UserProfile\dotsofis" -PathType Container)) {
    Write-Verbose -Message "Install my PowerShell dot files..."
    Start-Process -FilePath "PowerShell" -ArgumentList "git","clone","https://github.com/Sofistico/powershell_profile.git","$Env:UserProfile\dotsofis" -Wait -NoNewWindow
@'
New-Item -Path $Env:UserProfile\Documents\PowerShell -ItemType Directory -ErrorAction Ignore
Remove-Item -Path $Env:UserProfile\Documents\PowerShell\Profile.ps1 -Force
New-Item -Path $Env:UserProfile\Documents\PowerShell\Profile.ps1 -ItemType SymbolicLink -Target $Env:UserProfile\dotsofis\Profile.ps1
'@ > $Env:Temp\dotsofis.ps1
   Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\dotsofis.ps1" -Verb RunAs -Wait -WindowStyle Hidden
   Remove-Item -Path $Env:Temp\dotsofis.ps1 -Force
@'
'@ > $Env:Temp\submodule.ps1
    Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\submodule.ps1" -Wait -NoNewWindow
    Remove-Item -Path $Env:Temp\submodule.ps1 -Force
}

# todo: Configure to get my dotfiles for neovim and wezterm and/or any other install that i might need

Write-Output "Install complete! Please reboot your machine/worksation!"
Start-Sleep -Seconds 10

#You can get and run the entire script on a new machine by invoking the following command.

#PowerShell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Sofistico/powershell_profile/refs/heads/main/Config.ps1'))"
