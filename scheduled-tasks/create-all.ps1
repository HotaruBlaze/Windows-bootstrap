$scripts = @(
    "C:\Users\Phoenix\windows-bootstrap\scheduled-tasks\backup-games.ps1",
    "C:\Users\Phoenix\windows-bootstrap\scheduled-tasks\backup-other.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "Running script: $script"
        & "powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $script
    } else {
        Write-Host "Script not found: $script"
    }
}
