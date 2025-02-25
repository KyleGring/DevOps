# Apply_Fixes.ps1 - Force Apply Windows Defender & Privacy Optimizations
$logPath = ".\Logs\Apply_Log.txt"
if (!(Test-Path .\Logs)) { New-Item -ItemType Directory -Path .\Logs }

Write-Output "`n===== Applying Windows Defender & Privacy Fixes (Enforced) =====" | Tee-Object -FilePath $logPath

# Force Harden Windows Defender
Write-Output "`n[ Hardening Windows Defender ]" | Tee-Object -FilePath $logPath -Append
Set-MpPreference -PUAProtection Enabled
Set-MpPreference -EnableNetworkProtection Enabled
Set-MpPreference -MAPSReporting 0
Set-MpPreference -SubmitSamplesConsent 0
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableScriptScanning $false
Set-MpPreference -DisableBlockAtFirstSeen $false

# Disable Tamper Protection
Write-Output "`n[ Disabling Tamper Protection ]" | Tee-Object -FilePath $logPath -Append
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -Value 0

# Disable Telemetry (Force Mode)
Write-Output "`n[ Disabling Telemetry (Forced) ]" | Tee-Object -FilePath $logPath -Append
$telemetryKeys = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
)
foreach ($key in $telemetryKeys) {
    if (!(Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    Set-ItemProperty -Path $key -Name "AllowTelemetry" -Value 0
}

# Disable Remote Assistance & Remote Desktop
Write-Output "`n[ Disabling Remote Assistance & Remote Desktop ]" | Tee-Object -FilePath $logPath -Append
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowFullControl" -Value 0
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices).SetAllowTSConnections(0)

# Force Disable Cortana
Write-Output "`n[ Disabling Cortana (Forced) ]" | Tee-Object -FilePath $logPath -Append
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0

# Enforce Firewall Activation
Write-Output "`n[ Enabling Windows Firewall ]" | Tee-Object -FilePath $logPath -Append
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Write-Output "`nFixes Enforced. Log saved to $logPath"

