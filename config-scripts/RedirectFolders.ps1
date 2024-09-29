# Define the new base directory for redirection
$newBasePath = "D:\SYSTEM"

# Define user profile path
$userProfilePath = "C:\Users\Phoenix"

# Array of folder names to redirect
$foldersToRedirect = @(
    "Documents",
    "Downloads",
    "Music",
    "Pictures",
    "Videos"
)

# Loop through each folder and create a junction
foreach ($folder in $foldersToRedirect) {
    # Define the original and new folder paths
    $originalPath = Join-Path -Path $userProfilePath -ChildPath $folder
    $newPath = Join-Path -Path $newBasePath -ChildPath $folder
    
    # Check if the original folder exists
    if (Test-Path -Path $originalPath) {
        # Remove the original folder (be careful with this step!)
        Remove-Item -Path $originalPath -Recurse -Force
        
        # Create the new target folder
        New-Item -Path $newPath -ItemType Directory -Force
        
        # Create the junction
        New-Item -Path $originalPath -ItemType Junction -Value $newPath

        Write-Host "Redirected $folder from $originalPath to $newPath"
    } else {
        Write-Host "$originalPath does not exist, skipping redirection for $folder"
    }
}

Write-Host "Folder redirection complete."
