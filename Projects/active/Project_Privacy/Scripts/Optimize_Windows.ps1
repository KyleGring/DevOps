# Run as Admin
if (-not ([System.Security.Principal.WindowsPrincipal]([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "âš  This script requires Admin privileges. Relaunching as Admin..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "âš¡ Optimizing Windows Performance..."

# Disable Startup Bloat
Write-Host "ðŸ”¹ Disabling unnecessary startup apps..."
Get-AppxPackage *xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage *solitaire* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage *bingnews* | Remove-AppxPackage -ErrorAction SilentlyContinue
Write-Host "âœ… Startup Bloat Disabled"

# Clear Temp & Junk Files
Write-Host "ðŸ§¹ Clearing Temp & Junk Files..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "âœ… Temporary Files Cleared"

# Optimize CPU Performance
Write-Host "âš™ Optimizing CPU Performance..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name ClearPageFileAtShutdown -Value 1
Write-Host "âœ… CPU & Memory Optimized"

# Disable Power Throttling (Boosts Performance)
Write-Host "ðŸš€ Disabling Power Throttling for better performance..."
PowerCfg -attributes SUB_PROCESSOR 75b0ae3f-bce0-45a7-8c89-c9611c25e100 -attrib-hide
PowerCfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 75b0ae3f-bce0-45a7-8c89-c9611c25e100 0
PowerCfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR 75b0ae3f-bce0-45a7-8c89-c9611c25e100 0
PowerCfg -Apply
Write-Host "âœ… Power Throttling Disabled"

# Disable Background Apps (Reduces RAM Usage)
Write-Host "ðŸ›‘ Stopping Background Apps..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Value 0
Write-Host "âœ… Background Apps Disabled"

Write-Host "ðŸŽ¯ Windows Performance Optimization Completed Successfully!"


