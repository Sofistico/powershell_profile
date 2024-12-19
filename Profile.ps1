Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (&starship init powershell)

# Load work functions
$wf = "$PSScriptRoot\WorkFunctions.ps1"
if (Test-Path $wf -ErrorAction SilentlyContinue) {
  . $wf
}

$env:FZF_DEFAULT_OPTS=@"
--layout=reverse
--cycle
--scroll-off=5
--border
--preview-window=right,60%,border-left
--bind ctrl-u:preview-half-page-up
--bind ctrl-d:preview-half-page-down
--bind ctrl-f:preview-page-down
--bind ctrl-b:preview-page-up
--bind ctrl-g:preview-top
--bind ctrl-h:preview-bottom
--bind alt-w:toggle-preview-wrap
--bind ctrl-e:toggle-preview
"@

function _fzf_open_path
{
  param (
    [Parameter(Mandatory=$true)]
    [string]$input_path
  )
  if ($input_path -match "^.*:\d+:.*$")
  {
    $input_path = ($input_path -split ":")[0]
  }
  if (-not (Test-Path $input_path))
  {
    return
  }
  $cmds = @{
    'bat' = { bat $input_path }
    'cat' = { Get-Content $input_path }
    'cd' = {
      if (Test-Path $input_path -PathType Leaf)
      {
        $input_path = Split-Path $input_path -Parent
      }
      Set-Location $input_path
    }
    'nvim' = { nvim $input_path }
    'remove' = { Remove-Item -Recurse -Force $input_path }
    'echo' = { Write-Output $input_path }
  }
  $cmd = $cmds.Keys | fzf --prompt 'Select command> '
  & $cmds[$cmd]
}

function _fzf_get_path_using_fd
{
  $input_path = fd --type file --follow --hidden --exclude .git |
    fzf --prompt 'Files> ' `
      --header-first `
      --header 'CTRL-S: Switch between Files/Directories' `
      --bind 'ctrl-s:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
      --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always {} --style=plain) else (eza -T --colour=always --icons=always {})'
  return $input_path
}

function _fzf_get_path_using_rg
{
  $INITIAL_QUERY = "${*:-}"
  $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case"
  $input_path = "" |
    fzf --ansi --disabled --query "$INITIAL_QUERY" `
      --bind "start:reload:$RG_PREFIX {q}" `
      --bind "change:reload:sleep 0.1 & $RG_PREFIX {q} || rem" `
      --bind 'ctrl-s:transform:if not "%FZF_PROMPT%" == "1. ripgrep> " (echo ^rebind^(change^)^+^change-prompt^(1. ripgrep^> ^)^+^disable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-f ^& type %TEMP%\rg-fzf-r) else (echo ^unbind^(change^)^+^change-prompt^(2. fzf^> ^)^+^enable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-r ^& type %TEMP%\rg-fzf-f)' `
      --color 'hl:-1:underline,hl+:-1:underline:reverse' `
      --delimiter ':' `
      --prompt '1. ripgrep> ' `
      --preview-label 'Preview' `
      --header 'CTRL-S: Switch between ripgrep/fzf' `
      --header-first `
      --preview 'bat --color=always {1} --highlight-line {2} --style=plain' `
      --preview-window 'up,60%,border-bottom,+{2}+3/3'
  return $input_path
}

function fdg
{
  _fzf_open_path $(_fzf_get_path_using_fd)
}

function rgg
{
  _fzf_open_path $(_fzf_get_path_using_rg)
}


# SET KEYBOARD SHORTCUTS TO CALL FUNCTION

Set-PSReadLineKeyHandler -Key "Ctrl+t" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fdg")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key "Ctrl+g" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("rgg")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
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
