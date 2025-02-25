[System.Environment]::SetEnvironmentVariable("PROFILE", "C:\DevOps\PowerShell\Microsoft.PowerShell_profile.ps1", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("PowerShellProfilePath", "C:\DevOps\PowerShell", [System.EnvironmentVariableTarget]::Machine)

Write-Host "✅ PowerShell profile path updated in system environment variables."


