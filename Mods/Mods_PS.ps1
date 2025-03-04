﻿# PowerShell 7 & Windows Terminal Optimization
Write-Host "ðŸš€ Starting Windows Terminal & PowerShell 7 Optimization..." -ForegroundColor Cyan

# ----------------------------------------
# âœ… Install PowerShell 7 (if missing)
# ----------------------------------------
$pwshInstalled = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwshInstalled) {
    Write-Host "ðŸ”¹ Installing PowerShell 7..."
    winget install --id Microsoft.Powershell --source winget
}
else {
    Write-Host "âœ… PowerShell 7 is already installed."
}

# ----------------------------------------
# âœ… Set PowerShell 7 as Default Shell
# ----------------------------------------
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\PowerShell.exe' -Name '(Default)' -Value $pwshPath
Write-Host "âœ… PowerShell 7 set as system-wide default."

# ----------------------------------------
# âœ… Configure Windows Terminal Profiles
# ----------------------------------------
$TerminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Ensure Windows Terminal settings exist
if (-Not (Test-Path $TerminalSettingsPath)) {
    Write-Host "âš  Windows Terminal settings.json not found! Opening Windows Terminal once to generate it..."
    Start-Process "wt.exe"
    Start-Sleep -Seconds 3
}

# Read current settings
$settingsJson = Get-Content -Path $TerminalSettingsPath -Raw | ConvertFrom-Json

# Define New PowerShell 7 Profile
$pwshProfile = @{
    name              = "PowerShell 7"
    commandline       = $pwshPath
    guid              = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
    hidden            = $false
    startingDirectory = "C:\\DevOps"
    fontFace          = "Cascadia Code PL"
    fontSize          = 12
    useAcrylic        = $true
    acrylicOpacity    = 0.85
    cursorShape       = "bar"
    colorScheme       = "One Half Dark"
}

# Define Git Bash Profile (if installed)
$gitBashPath = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBashPath) {
    $gitBashProfile = @{
        name              = "Git Bash"
        commandline       = $gitBashPath
        guid              = "{00000000-0000-0000-0000-000000000000}"
        hidden            = $false
        startingDirectory = "C:\\DevOps"
        fontFace          = "Cascadia Code PL"
        fontSize          = 12
        cursorShape       = "bar"
        colorScheme       = "One Half Dark"
    }
    $settingsJson.profiles.list += $gitBashProfile
}

# Add PowerShell 7 Profile
$settingsJson.profiles.list += $pwshProfile

# Set PowerShell 7 as the default profile
$settingsJson.defaultProfile = $pwshProfile.guid

# Save updated settings
$settingsJson | ConvertTo-Json -Depth 100 | Set-Content -Path $TerminalSettingsPath -Encoding UTF8
Write-Host "âœ… Windows Terminal profiles updated with PowerShell 7 and Git Bash."

# ----------------------------------------
# âœ… Set PowerShell Profile for Optimal Settings
# ----------------------------------------
$profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Create profile if missing
if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# Append useful settings
@"
# PowerShell 7 Custom Profile
Set-Location C:\DevOps
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -BellStyle None
Set-Alias ll Get-ChildItem
Set-Alias grep Select-String
Set-Alias vim nvim

# Admin Mode Toggle
function Start-Admin {
    Start-Process pwsh -Verb RunAs
}

# Auto-load SSH Keys
if (Test-Path "~\.ssh\id_rsa") {
    Start-SshAgent
    ssh-add ~\.ssh\id_rsa | Out-Null
}

# Load 1Password CLI (if installed)
if (Get-Command op -ErrorAction SilentlyContinue) {
    Write-Host "ðŸ” 1Password CLI detected. Signing in..."
    $opSession = & op signin my.1password.com --raw
    if ($opSession) {
        $env:OP_SESSION = $opSession
        Write-Host "âœ… 1Password CLI session loaded."
    } else {
        Write-Host "âš  1Password CLI sign-in failed. Manual login required."
    }
}

Write-Host "âœ… PowerShell 7 profile loaded!"
"@ | Set-Content -Path $profilePath -Encoding UTF8

Write-Host "âœ… PowerShell 7 profile configured at: $profilePath"

# ----------------------------------------
# âœ… Final Verification & Cleanup
# ----------------------------------------
Write-Host "ðŸ”„ Restarting Windows Terminal to apply changes..."
Stop-Process -Name "WindowsTerminal" -Force -ErrorAction SilentlyContinue
Start-Process "wt.exe"
Write-Host "ðŸš€ Setup Complete! PowerShell 7 is now the default shell." -ForegroundColor Green


