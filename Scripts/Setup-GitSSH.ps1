# Script: Setup-GitSSH.ps1
# Automates SSH Key creation, storage in 1Password, and Git setup

$KEY_NAME = "GitHub-Key"
$KEY_PATH = "$env:USERPROFILE\.ssh\id_rsa_github"
$GITHUB_USER = "KyleGring"

Write-Host "🔐 Generating new SSH key for GitHub..." -ForegroundColor Cyan
ssh-keygen -t rsa -b 4096 -C "$GITHUB_USER@gmail.com" -f $KEY_PATH -N ""

# Ensure SSH Agent is running
Write-Host "🟢 Starting SSH Agent..."
Start-Service ssh-agent
ssh-add $KEY_PATH

Write-Host "✅ SSH Key Generated and Added to SSH Agent!"

# Store SSH Key in 1Password
if (Get-Command op -ErrorAction SilentlyContinue) {
    Write-Host "🔑 Storing SSH Key in 1Password..."
    op item create --vault "Development" --title $KEY_NAME --section "SSH" --field "private_key=$(Get-Content $KEY_PATH -Raw)"
    op item create --vault "Development" --title $KEY_NAME --section "SSH" --field "public_key=$(Get-Content $KEY_PATH.pub -Raw)"
    Write-Host "✅ SSH Key securely stored in 1Password!"
} else {
    Write-Host "⚠ 1Password CLI (`op`) not found! Install it to store keys securely."
}

# Add SSH Key to GitHub (if using GitHub CLI)
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "🔗 Adding SSH Key to GitHub..."
    $PUB_KEY = Get-Content "$KEY_PATH.pub" -Raw
    echo $PUB_KEY | gh ssh-key add -t "GitHub SSH Key"
    Write-Host "✅ SSH Key added to GitHub!"
} else {
    Write-Host "⚠ GitHub CLI (`gh`) not found! Manually add the key to GitHub."
}

# Set SSH for GitHub
Write-Host "🔄 Configuring Git to use SSH..."
git config --global user.name "$GITHUB_USER"
git config --global user.email "$GITHUB_USER@gmail.com"
git config --global core.sshCommand "ssh -i $KEY_PATH"

Write-Host "✅ Git is now configured to use the new SSH key!"

# Test SSH Connection
Write-Host "🔍 Testing SSH connection to GitHub..."
ssh -T git@github.com

Write-Host "🚀 Git SSH Key Setup Complete!"
