# Run as Admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$WiFiAdapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -match "Wi-Fi" }
if (-not $WiFiAdapter) {
    Write-Host "âŒ No Wi-Fi adapter found. Exiting..." -ForegroundColor Red
    exit
}

$AdapterName = $WiFiAdapter.Name
Write-Host "Optimizing Wi-Fi adapter: $AdapterName"

netsh wlan set autoconfig enabled=yes interface="$AdapterName"
netsh wlan set profileparameter name="$AdapterName" preferredband=5
Write-Host "Preferred Band set to 5GHz"

Set-NetAdapterPowerManagement -Name "$AdapterName" -AllowComputerToTurnOffDevice False -ErrorAction SilentlyContinue
Write-Host "Power Saving Disabled"

Set-NetAdapterAdvancedProperty -Name "$AdapterName" -RegistryKeyword "RoamAggressiveness" -RegistryValue 1 -ErrorAction SilentlyContinue
Write-Host "Roaming Aggressiveness Optimized"


