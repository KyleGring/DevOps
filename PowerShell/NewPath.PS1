$NewProfilePath = "C:\DevOps\PowerShell\Microsoft.PowerShell_profile.ps1"

# Set system-wide PowerShell profile location
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name "Personal" -Value "C:\DevOps\PowerShell"

# Update profile path in PowerShell registry keys
Set-ItemProperty -Path "HKCU:\Software\Microsoft\PowerShell\7" -Name "DefaultProfile" -Value $NewProfilePath
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\7" -Name "DefaultProfile" -Value $NewProfilePath

Write-Host "✅ Registry updated to use PowerShell profile in $NewProfilePath"


