# Run as Admin
if (-not ([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Setting UTF-8 BOM as the default encoding system-wide..."

# 1️⃣ Set Notepad Default Encoding to UTF-8 BOM
Write-Host "Updating Windows Notepad to use UTF-8 BOM by default..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Notepad" -Name "iDefaultEncoding" -Type DWord -Value 1 -ErrorAction SilentlyContinue

# 2️⃣ Update VS Code Default Encoding to UTF-8 BOM
$VSCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $VSCodeSettingsPath) {
    Write-Host "Updating VS Code settings for UTF-8 BOM..."
    $VSCodeSettings = Get-Content -Path $VSCodeSettingsPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    if (-not $VSCodeSettings."files.encoding") {
        $VSCodeSettings | Add-Member -MemberType NoteProperty -Name "files.encoding" -Value "utf8bom"
    } else {
        $VSCodeSettings."files.encoding" = "utf8bom"
    }
    $VSCodeSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $VSCodeSettingsPath -Encoding UTF8
}

# 3️⃣ Convert all PowerShell scripts in a folder to UTF-8 BOM
$ScriptsPath = "C:\DevOps\Projects\active\Windows_Privacy_Optimization\Scripts"
if (Test-Path $ScriptsPath) {
    Write-Host "Converting all .ps1 scripts to UTF-8 BOM..."
    Get-ChildItem -Path $ScriptsPath -Filter "*.ps1" | ForEach-Object {
        $Content = Get-Content -Path $_.FullName
        [System.IO.File]::WriteAllLines($_.FullName, $Content, (New-Object System.Text.UTF8Encoding $true))
    }
}

Write-Host "✅ UTF-8 BOM is now the default encoding system-wide!"


