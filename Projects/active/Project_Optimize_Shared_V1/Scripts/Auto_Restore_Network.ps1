# Run as Admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$LogFile = "$PSScriptRoot\..\Logs\AutoRestore.log"

function Log {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -Append -FilePath $LogFile
}

Log "=== Network Auto-Restore Started ==="

$Network = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notmatch "Virtual" }
if (-not $Network) {
    Log "âŒ No active network detected. Exiting..."
    exit
}

$Interface = $Network.Name
Log "Monitoring network: $Interface"

while ($true) {
    $InternetStatus = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet
    if (-not $InternetStatus) {
        Log "âŒ Internet down! Resetting to DHCP..."
        netsh interface ip set address name="$Interface" dhcp
        netsh interface ip set dns name="$Interface" dhcp
        Start-Sleep -Seconds 5
        Log "âœ… DHCP Restored. Rechecking Internet..."
    }
    else {
        Log "âœ” Internet OK."
    }
    Start-Sleep -Seconds 30
}


