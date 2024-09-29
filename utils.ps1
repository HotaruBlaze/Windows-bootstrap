# utils.ps1

function Log-Message {
    param (
        [string]$Message,
        [string]$LogFile
    )
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    
    Add-Content -Path $LogFile -Value $logEntry
}
