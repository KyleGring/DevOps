# 🚀 PowerShell Elite Profile Setup 🚀

# ✅ Set Default Working Directory
Set-Location C:\DevOps

# ✅ Improve History Behavior
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -BellStyle None

# ✅ Command Aliases for Speed
Set-Alias ll Get-ChildItem
Set-Alias grep Select-String
Set-Alias vim nvim
Set-Alias cls Clear-Host

# ✅ Optimize Tab Completion
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Chord "Ctrl+d" -Function DeleteChar
Set-PSReadLineKeyHandler -Chord "Ctrl+z" -Function Undo

# ✅ Function: Restart as Admin
function Start-Admin {
    Start-Process pwsh -Verb RunAs
}

# ✅ Function: Quickly Open Profile
function Edit-Profile {
    code $PROFILE
}

# ✅ Auto-Load SSH Keys
if (Test-Path "~\.ssh\id_rsa") {
    Start-SshAgent
    ssh-add ~\.ssh\id_rsa | Out-Null
}

# ✅ Auto-Load 1Password CLI (if installed)
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

# ✅ Clean Up Default Noise
$global:ProgressPreference = 'SilentlyContinue'
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

Write-Host "✅ PowerShell profile loaded!" -ForegroundColor Green

