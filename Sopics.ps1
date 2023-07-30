##### Start of user config #####

# Set the path to the ExifTool executable
$exifToolPath = "C:\Users\Jeff\Desktop\exiftool.exe"
# Set the path to the directory containing the media
$directory = "C:\SOURCE_HERE"
# Set the path to the directory that should hold files without a date
$noDateFolder = "C:\UNKNOWN_DATES_HERE"

##### End of user config #####


New-Item -ItemType Directory -Path $noDateFolder -Force | Out-Null

# Get all the files in the specified directory
$files = Get-ChildItem -Path $directory -file
$totalMedia = $files.count

# Counters
$mediaPosition = 0
$totalMedia = 0
$sortedMedia = 0
$nodateMedia = 0

foreach ($file in $files) {
    $mediaPosition++

    $output = & $exifToolPath -DateTimeOriginal -s -s -s -d "%Y-%m" $file.FullName

    if ([string]::IsNullOrWhiteSpace($output)) {
        # Try checking file creation date 
        $output = & $exifToolPath -CreateDate -s -s -s -d "%Y-%m" $file.FullName
    }

    if ([string]::IsNullOrWhiteSpace($output)) {
        # Try checking file modification date	
        $output = & $exifToolPath -FileModifyDate -s -s -s -d "%Y-%m" $file.FullName
    }

    if ([string]::IsNullOrWhiteSpace($output)) {
        # Move the file to the NODATE directory
        $nodateMedia++
        $destination = Join-Path -Path $noDateFolder -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destination -Force
    }
    else {
        $sortedMedia++
        # Create a folder based on the date taken (YYYY-MM format)
        $dateFolder = Join-Path -Path $directory -ChildPath $output
        New-Item -ItemType Directory -Path $dateFolder -Force | Out-Null

        # Move the file to the corresponding date folder
        $destination = Join-Path -Path $dateFolder -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destination -Force
    }

    Write-Host "Progress: $mediaPosition / $totalMedia"
    Write-Host "Sorted files: $sortedMedia"
    Write-Host "Unknown date files: $nodateMedia"
}

Write-Host "Summary"
Write-Host "$sortedMedia files sorted out of $totalMedia"
Write-Host "$nodateMedia files could not be sorted"

Write-Host "-- SOPICS DONE --"
