# Extract_Settings.ps1 - Extract and log Windows Defender & telemetry settings

$logPath = ".\Logs\Extract_Log.txt"
if (!(Test-Path .\Logs)) { New-Item -ItemType Directory -Path .\Logs }

Write-Output "`n===== Extracting Current Windows Defender & Telemetry Settings =====" | Tee-Object -FilePath $logPath

# Windows Defender Status
Write-Output "`n[ Windows Defender Settings ]" | Tee-Object -FilePath $logPath -Append
Get-MpPreference | Format-List | Tee-Object -FilePath $logPath -Append

# Firewall Status
Write-Output "`n[ Firewall Status ]" | Tee-Object -FilePath $logPath -Append
(Get-NetFirewallProfile | Select-Object Name, Enabled) | Format-Table | Tee-Object -FilePath $logPath -Append

# Telemetry Settings
Write-Output "`n[ Telemetry Settings ]" | Tee-Object -FilePath $logPath -Append
$telemetryKeys = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
)
foreach ($key in $telemetryKeys) {
    if (Test-Path $key) {
        Get-ItemProperty -Path $key | Format-List | Tee-Object -FilePath $logPath -Append
    }
    else {
        Write-Output "Key not found: $key" | Tee-Object -FilePath $logPath -Append
    }
}

# Remote Assistance & Remote Desktop
Write-Output "`n[ Remote Assistance & Remote Desktop ]" | Tee-Object -FilePath $logPath -Append
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" | Tee-Object -FilePath $logPath -Append
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices).AllowTSConnections | Tee-Object -FilePath $logPath -Append

Write-Output "`nExtraction Complete. Log saved to $logPath"
# Placeholder for Extract_Settings.ps1
Write-Output 'Extract Settings Script - Placeholder'

