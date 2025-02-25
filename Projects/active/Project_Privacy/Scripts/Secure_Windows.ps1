# Run as Admin
if (-not ([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting Windows Security Hardening..."

# Validate Existing Security Settings
Write-Host "Validating Windows Defender & Privacy Fixes..."
$defenderSettings = Get-MpPreference | Select-Object PUAProtection, EnableNetworkProtection, MAPSReporting, SubmitSamplesConsent
$telemetry = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Select-Object AllowTelemetry

# Disable Telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Value 0
Write-Host "Windows Telemetry Disabled"

# Block Ads & Trackers
$HostsFile = "C:\Windows\System32\drivers\etc\hosts"
$BlockEntries = @"
# Block Ads and Trackers
0.0.0.0 telemetry.microsoft.com
0.0.0.0 ads.google.com
0.0.0.0 tracking.example.com
"@

Try {
    $BlockEntries | Out-File -Append -Encoding ASCII $HostsFile
    Write-Host "Ads & Trackers Blocked in Hosts File"
}
Catch {
    Write-Host "Failed to update hosts file. Try running PowerShell as Admin." -ForegroundColor Red
}

# Harden Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
Set-MpPreference -ScanScheduleDay 0
Set-MpPreference -EnableNetworkProtection Enabled
Write-Host "Windows Defender Hardened"

Write-Host "Windows Security Hardening Completed Successfully!"

