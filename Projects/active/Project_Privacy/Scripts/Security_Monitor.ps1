# Schedule Daily Security Validation Task
$taskName = "WindowsSecurityMonitor"
$scriptPath = "C:\DevOps\Projects\active\Windows_Privacy_Optimization\Secure_Windows.ps1"

Write-Output "Creating Scheduled Task for Daily Security Validation..."

# Delete existing task if it exists
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Create scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 10:00AM
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -User "SYSTEM" -Action $action -RunLevel Highest -Force

Write-Output "Scheduled Task Created: Runs daily at 10:00 AM."

