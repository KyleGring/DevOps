# Auto Restore Network - Monitors & Restores Internet

# Run as Admin
if (-not ([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$logPath = "$PSScriptRoot\..\Logs\AutoRestore_Network_Log.txt"
Write-Output "Starting Network Auto-Restore Monitoring..." | Out-File -Append -FilePath $logPath

$Network = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
if (-not $Network) {
    Write-Output "âŒ No active network detected. Exiting..." | Out-File -Append -FilePath $logPath
    exit
}

$Interface = $Network.Name
Write-Output "Monitoring network: $Interface" | Out-File -Append -FilePath $logPath

while ($true) {
    $InternetStatus = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet
    if (-not $InternetStatus) {
        Write-Output "âŒ Internet down! Resetting to DHCP..." | Out-File -Append -FilePath $logPath
        netsh interface ip set address name="$Interface" dhcp
        netsh interface ip set dns name="$Interface" dhcp
        Start-Sleep -Seconds 5
    }
    else {
        Write-Output "âœ” Internet OK." | Out-File -Append -FilePath $logPath
    }
    Start-Sleep -Seconds 30
}

