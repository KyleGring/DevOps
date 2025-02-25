# Setup_ScheduledTask.ps1 - Automate Daily Security Validation & Auto-Fix
$taskName = "WindowsPrivacyMonitor"
$validationScript = "C:\DevOps\Projects\active\Windows_Privacy_Optimization\Validate_Fixes.ps1"
$fixScript = "C:\DevOps\Projects\active\Windows_Privacy_Optimization\Apply_Fixes.ps1"

Write-Output "Creating Scheduled Task for Daily Security Validation..."

# Delete existing task if it exists
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Create scheduled task action (Validation)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$validationScript`""
$trigger = New-ScheduledTaskTrigger -Daily -At 10:00AM
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -User "SYSTEM" -Action $action -RunLevel Highest -Force

# Auto-apply fixes if needed
$actionFix = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$fixScript`""
$triggerFix = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "$taskName-Fix" -Trigger $triggerFix -User "SYSTEM" -Action $actionFix -RunLevel Highest -Force

Write-Output "Scheduled task created: Runs daily at 10:00 AM. Auto-fix applies on startup if needed."

