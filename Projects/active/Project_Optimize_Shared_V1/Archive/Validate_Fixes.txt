# Validate_Fixes.ps1 - Structured Log Reporting for Windows Privacy & Security

$logPath = ".\Logs\Validate_Log.txt"
$csvPath = ".\Logs\Validate_Report.csv"
$jsonPath = ".\Logs\Validate_Report.json"
$report = @()

if (!(Test-Path .\Logs)) { New-Item -ItemType Directory -Path .\Logs }

Write-Output "`n===== Validating Windows Defender & Privacy Fixes =====" | Tee-Object -FilePath $logPath

# Validate Defender Settings
Write-Output "`n[ Checking Windows Defender Status ]" | Tee-Object -FilePath $logPath -Append
$defenderSettings = Get-MpPreference | Select-Object PUAProtection, EnableNetworkProtection, MAPSReporting, SubmitSamplesConsent
$report += $defenderSettings | ConvertTo-Csv -NoTypeInformation

# Validate Telemetry
Write-Output "`n[ Checking Telemetry Settings ]" | Tee-Object -FilePath $logPath -Append
$telemetry = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Select-Object AllowTelemetry
$report += $telemetry | ConvertTo-Csv -NoTypeInformation

# Validate Remote Assistance & Remote Desktop
Write-Output "`n[ Checking Remote Assistance & Remote Desktop Status ]" | Tee-Object -FilePath $logPath -Append
$remote = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" | Select-Object fAllowToGetHelp, fAllowFullControl
$report += $remote | ConvertTo-Csv -NoTypeInformation

# Save structured logs
$report | Out-File -FilePath $csvPath -Encoding utf8
$report | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding utf8

Write-Output "`nValidation Complete. Logs saved to $csvPath and $jsonPath"

