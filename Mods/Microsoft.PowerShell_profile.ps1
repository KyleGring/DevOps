# ========================
# 🚀 PowerShell Elite Profile
# ========================
Write-Host "🔹 PowerShell Profile Loaded!" -ForegroundColor Cyan

# ✅ Set Default Working Directory
Set-Location C:\DevOps

# ✅ Enable PowerShell Predictive IntelliSense
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -BellStyle None

# ✅ Fast Aliases (Navigation & File Ops)
Set-Alias ll Get-ChildItem
Set-Alias la "Get-ChildItem -Force"
Set-Alias grep Select-String
Set-Alias vim nvim

# ✅ Admin Mode Toggle
function Start-Admin {
    Start-Process pwsh -Verb RunAs
}

# ✅ Quick File Editing (Auto-Detect)
function edit {
    param([string]$file)
    if (Test-Path $file) {
        if ($file -match "\.ps1$") {
            code $file  # Open in VS Code
        } else {
            notepad++ $file  # Open in Notepad++
        }
    } else {
        Write-Host "❌ File not found: $file" -ForegroundColor Red
    }
}

# ✅ Load SSH Keys Automatically
if (Test-Path "~\.ssh\id_rsa") {
    Start-SshAgent
    ssh-add ~\.ssh\id_rsa | Out-Null
    Write-Host "🔑 SSH Key Loaded!"
}

# ✅ Load 1Password CLI Session
if (Get-Command op -ErrorAction SilentlyContinue) {
    Write-Host "🔐 1Password CLI detected. Signing in..."
    $opSession = & op signin my.1password.com --raw
    if ($opSession) {
        $env:OP_SESSION = $opSession
        Write-Host "✅ 1Password CLI session loaded."
    } else {
        Write-Host "⚠ 1Password CLI sign-in failed. Manual login required."
    }
}

Write-Host "✅ PowerShell Profile Optimized!" -ForegroundColor Green


