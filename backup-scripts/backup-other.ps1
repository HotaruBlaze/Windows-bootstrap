# Get the path of the current script's directory
$scriptDirectory = $PSScriptRoot

# Define the path to the JSON configuration file
$configFilePath = Join-Path -Path $scriptDirectory -ChildPath "backup-config.json"

# Load the JSON configuration file
$config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json

# Define the folders to back up
$foldersToBackup = @(
    "$HOME\.ssh",
    "$HOME\.kube",
    "$HOME\.vscode",
    "$HOME\.gitconfig"
)

# Define the backup destination
$backupDestination = $config.backupLocation + "\" + "Users" + "\" + $env:USERNAME

# Create the backup destination directory if it doesn't exist
if (-Not (Test-Path -Path $backupDestination)) {
    New-Item -Path $backupDestination -ItemType Directory -Force
}

# Loop through each folder to back up
foreach ($folder in $foldersToBackup) {
    $folderName = Split-Path -Path $folder -Leaf
    $backupPath = Join-Path -Path $backupDestination -ChildPath $folderName

    # Check if the folder exists
    if (Test-Path -Path $folder) {
        # Copy the folder to the backup destination
        Copy-Item -Path $folder -Destination $backupPath -Recurse -Force

        Write-Host "Backed up $folder to $backupPath"
    } else {
        Write-Host "$folder does not exist, skipping."
    }
}

Write-Host "Backup process complete."
