$scriptPath = "C:\Users\Phoenix\windows-bootstrap\backup-scripts\backup-other.ps1"
$taskName = "[Phoenix Backups] Backup Other on Login"
$taskDescription = "Runs backup-other.ps1 whenever the user logs in."

$existingTask = schtasks.exe /query /tn $taskName 2>$null
if ($existingTask) {
    Write-Host "Task '$taskName' already exists. Removing the old task..."
    schtasks.exe /delete /tn $taskName /f
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"" 
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger $trigger -User "$env:USERNAME"
Set-ScheduledTask -TaskName $taskName -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Hidden)

Write-Host "Scheduled task '$taskName' created successfully to run at user logon."
