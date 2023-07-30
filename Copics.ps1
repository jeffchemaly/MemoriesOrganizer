##### Start of user config #####

# Set the path to the directory containing the pictures
$sourceDirectory = "C:\SOURCE_HERE"
# Set the path to the directory where the unique pictures should be moved to
$destinationDirectory = "C:\DESTINATION_HERE"

##### End of user config #####


# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $destinationDirectory)) {
    New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
}

# Define the supported image file extensions
$imageExtensions = @("*.jpg", "*.jpeg", "*.png", "*.bmp")

# Define the supported video file extensions
$videoExtensions = @("*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv")

# Combine the image and video extensions
$allExtensions = $imageExtensions + $videoExtensions

# Get all files (pictures and videos) from the source directory
$files = Get-ChildItem -Path $sourceDirectory -Include $allExtensions -File -Recurse

foreach ($file in $files) {
    $destinationPath = Join-Path -Path $destinationDirectory -ChildPath $file.Name
    
    # Check if the file already exists in the destination directory
    if (Test-Path -Path $destinationPath) {
        # Compare the hashes of the source and destination files
        $sourceHash = Get-FileHash -Path $file.FullName
        $destinationHash = Get-FileHash -Path $destinationPath
        
        # If the hashes are the same, skip copying the duplicate file
        if ($sourceHash.Hash -eq $destinationHash.Hash) {
            Write-Host "Skipping duplicate: $($file.FullName)"
            continue
        }
    }
    
    # Copy the file to the destination directory
    Copy-Item -Path $file.FullName -Destination $destinationPath -Force
    Write-Host "Copied: $($file.FullName)"
}

Write-Host "-- COPICS DONE --"
