winget install --id Git.Git -e --source winget
winget install ajeetdsouza.zoxide
winget install fzf
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
winget install nvim
