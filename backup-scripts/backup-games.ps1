# Get the path of the current script's directory
$scriptDirectory = $PSScriptRoot

# Define the path to the JSON configuration file
$configFilePath = Join-Path -Path $scriptDirectory -ChildPath "./backup-config.json"

# Define the log file path
$logFilePath = Join-Path -Path $scriptDirectory -ChildPath "../logs/backup-games.txt"

# Load utility functions
. (Join-Path -Path $scriptDirectory -ChildPath "..\utils.ps1")

# Load the JSON configuration file
$config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json

# General backup location
$backupLocation = $config.backupLocation

# Backup Ludusavi
$ludusaviBackupPath = Join-Path -Path $backupLocation -ChildPath $config.ludusavi.backupPath
$ludusaviOptions = $config.ludusavi.options -split ' '

# Create the backup destination for Ludusavi if it doesn't exist
if (-Not (Test-Path -Path $ludusaviBackupPath)) {
    New-Item -Path $ludusaviBackupPath -ItemType Directory -Force
    Log-Message "Created backup destination: $ludusaviBackupPath" -LogFile $logFilePath
}

# Delete the log file if it exists
if (Test-Path -Path $logFilePath) {
    Remove-Item -Path $logFilePath
}

# Function to find Ludusavi executable
function Find-Ludusavi {
    $ludusaviExecutable = "Ludusavi.exe"
    $ludusaviPath = Get-Command $ludusaviExecutable -ErrorAction SilentlyContinue

    if (-not $ludusaviPath) {
        Log-Message "Ludusavi executable not found in the system PATH. Attempting to refresh the environment..." -LogFile $logFilePath
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
        
        $ludusaviPath = Get-Command $ludusaviExecutable -ErrorAction SilentlyContinue
        
        if (-not $ludusaviPath) {
            Log-Message "Still unable to find Ludusavi after refreshing environment. Exiting..." -LogFile $logFilePath
            Write-Host "Still unable to find Ludusavi after refreshing environment. Exiting..."
            exit 1
        }
    }

    return $ludusaviPath.Source
}


$ludusaviExecutable = Find-Ludusavi
if ($ludusaviExecutable) {
    Log-Message "Backing up Ludusavi to $ludusaviBackupPath with options: $ludusaviOptions" -LogFile $logFilePath
    $ludusaviCommand = @($ludusaviOptions + "--path", $ludusaviBackupPath)
    Log-Message "Executing command: $ludusaviExecutable $($ludusaviCommand -join ' ')" -LogFile $logFilePath
    Write-Host "Executing command: $ludusaviExecutable $($ludusaviCommand -join ' ')"
    
    try {
        $process = Start-Process -FilePath $ludusaviExecutable -ArgumentList $ludusaviCommand -RedirectStandardOutput "output.txt" -RedirectStandardError "error.txt" -NoNewWindow -PassThru
        $process.WaitForExit()

        $output = Get-Content -Path "output.txt" -Raw
        $errorOutput = Get-Content -Path "error.txt" -Raw
        Log-Message "Ludusavi output:" -LogFile $logFilePath
        Log-Message "$output" -LogFile $logFilePath
        
        Write-Host "Ludusavi returned Exit code $LASTEXITCODE."
        Log-Message "Ludusavi backup completed successfully!" -LogFile $logFilePath

        Remove-Item -Path "output.txt"
        Remove-Item -Path "error.txt"
    } catch {
        Log-Message "Error during Ludusavi backup: $_" -LogFile $logFilePath
        Write-Host "Error during Ludusavi backup: $_"
    }
} else {
    Log-Message "Error: Ludusavi executable could not be found after refresh." -LogFile $logFilePath
    Write-Host "Error: Ludusavi executable could not be found after refresh."
    exit 1
}