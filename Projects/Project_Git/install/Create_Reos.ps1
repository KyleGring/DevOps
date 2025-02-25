if (-Not (gh repo view "`$GitHubUser/`$(`$Repo.Name)" 2>`$null)) {
    Write-Output "ðŸ“¦ Creating repository: `$(`$Repo.Name)"
    gh repo create "`$(`$Repo.Name)" --private --description "`$(`$Repo.Desc)"
}

if (-Not (Test-Path "`$RepoDir")) {
    gh repo clone "`$GitHubUser/`$(`$Repo.Name)" "`$RepoDir"
}

# Create initial files
Set-Content -Path "`$RepoDir\README.md" -Value "# `$(`$Repo.Name)"
Set-Content -Path "`$RepoDir\.gitignore" -Value "venv/\n__pycache__/\n*.log"

# Git commit & push
cd "`$RepoDir"
git add .
git commit -m "Initial commit"
git push origin main


