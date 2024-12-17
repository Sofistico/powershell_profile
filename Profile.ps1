Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (&starship init powershell)

# Load work functions
$wf = "$PSScriptRoot\WorkFunctions.ps1"
if (Test-Path $wf -ErrorAction SilentlyContinue) {
  . $wf
}

# A shortcut I used in unix regularly
function ll { Get-ChildItem -Force $args }

# Still allow me to use gco alias
function Get-GitCheckout {
  [alias("gco")]
  param()
  git checkout $args
}
# Regularly used in unix, but now for Windows
function which { param($bin) Get-Command $bin }
# Another unix regular that I wanted to replicate for Windows
function Watch-Command {
  [alias('watch')]
  [CmdletBinding()]
  param (
    [Parameter()]
    [ScriptBLock]
    $Command,
    [Parameter()]
    [int]
    $Delay = 2
  )
  while ($true) {
    Clear-Host
    Write-Host ("Every {1}s: {0} `n" -F $Command.toString(), $Delay)
    $Command.Invoke()
    Start-Sleep -Seconds $Delay
  }
}

function gitacp {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [String[]] $message
    )
    if($null -eq $message){
        echo "> message is null"
        return
    }
    echo "> git add ."
    git add .

    echo "> git commit -a -m '$message'"

    git commit -a -m "$message"

    echo "> git push"
    git push
}

Set-Alias -Name v -Value nvim

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
