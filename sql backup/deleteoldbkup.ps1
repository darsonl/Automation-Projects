# PowerShell Script to Delete the Oldest File in Multiple Directories
# Author: Assistant
# Description: Deletes the oldest file in each of 4 specified target directories with logging (SILENT MODE)

# Define your target directories here
$targetDirectories = @(
    "C:\Path\To\Directory1",
    "C:\Path\To\Directory2", 
    "C:\Path\To\Directory3",
    "C:\Path\To\Directory4"
)

# Configuration
$silentMode = $true  # Set to $false if you want confirmation prompts

# Logging configuration
$logDirectory = "D:\BK\Logs"
$logFileName = "DeleteOldestFiles_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$logFilePath = Join-Path -Path $logDirectory -ChildPath $logFileName

# Create log directory if it doesn't exist
if (-not (Test-Path -Path $logDirectory)) {
    try {
        New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
        Write-Host "Created log directory: $logDirectory" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create log directory: $logDirectory. Error: $($_.Exception.Message)"
        exit 1
    }
}

# Function to write to both console and log file
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Color = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to console with color
    Write-Host $Message -ForegroundColor $Color
    
    # Write to log file
    try {
        Add-Content -Path $logFilePath -Value $logEntry -Encoding UTF8
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}

# Function to delete the oldest file in a directory
function Remove-OldestFile {
    param(
        [string]$DirectoryPath
    )
    
    try {
        # Check if directory exists
        if (-not (Test-Path -Path $DirectoryPath)) {
            Write-Log "Directory does not exist: $DirectoryPath" -Level "WARNING" -Color "Yellow"
            return
        }
        
        # Get all files in the directory (excluding subdirectories)
        $files = Get-ChildItem -Path $DirectoryPath -File | Where-Object { -not $_.PSIsContainer }
        
        if ($files.Count -eq 0) {
            Write-Log "No files found in directory: $DirectoryPath" -Level "INFO" -Color "Yellow"
            return
        }
        
        # Find the oldest file based on CreationTime
        $oldestFile = $files | Sort-Object CreationTime | Select-Object -First 1
        
        Write-Log "Processing directory: $DirectoryPath" -Level "INFO" -Color "Cyan"
        Write-Log "  Oldest file found: $($oldestFile.Name)" -Level "INFO" -Color "White"
        Write-Log "  Created: $($oldestFile.CreationTime)" -Level "INFO" -Color "White"
        Write-Log "  Size: $([math]::Round($oldestFile.Length / 1MB, 2)) MB" -Level "INFO" -Color "White"
        Write-Log "  Full path: $($oldestFile.FullName)" -Level "INFO" -Color "Gray"
        
        # Delete file automatically or ask for confirmation based on $silentMode
        if ($silentMode) {
            # Silent mode - delete automatically
            Remove-Item -Path $oldestFile.FullName -Force
            Write-Log "  File deleted automatically (silent mode): $($oldestFile.Name)" -Level "SUCCESS" -Color "Green"
            Write-Log "  Deleted file path: $($oldestFile.FullName)" -Level "SUCCESS" -Color "Green"
        } else {
            # Interactive mode - ask for confirmation
            $confirmation = Read-Host "Delete this file? (y/N)"
            
            if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
                Remove-Item -Path $oldestFile.FullName -Force
                Write-Log "  File deleted successfully: $($oldestFile.Name)" -Level "SUCCESS" -Color "Green"
                Write-Log "  Deleted file path: $($oldestFile.FullName)" -Level "SUCCESS" -Color "Green"
            } else {
                Write-Log "  File deletion cancelled by user: $($oldestFile.Name)" -Level "INFO" -Color "Yellow"
            }
        }
        
    }
    catch {
        Write-Log "Error processing directory '$DirectoryPath': $($_.Exception.Message)" -Level "ERROR" -Color "Red"
    }
}

# Main script execution
$modeText = if ($silentMode) { "SILENT MODE" } else { "INTERACTIVE MODE" }
Write-Log "=== Delete Oldest Files Script Started ($modeText) ===" -Level "INFO" -Color "Magenta"
Write-Log "Script execution started at: $(Get-Date)" -Level "INFO" -Color "Magenta"
Write-Log "Log file location: $logFilePath" -Level "INFO" -Color "Magenta"
Write-Log "Processing $($targetDirectories.Count) directories..." -Level "INFO" -Color "Magenta"
if ($silentMode) {
    Write-Log "Running in SILENT MODE - files will be deleted automatically without confirmation" -Level "WARNING" -Color "Yellow"
}
Write-Log "" -Level "INFO" -Color "White"

# Log the target directories
Write-Log "Target directories:" -Level "INFO" -Color "Cyan"
for ($i = 0; $i -lt $targetDirectories.Count; $i++) {
    Write-Log "  $($i + 1). $($targetDirectories[$i])" -Level "INFO" -Color "White"
}
Write-Log "" -Level "INFO" -Color "White"

# Loop through each target directory
$processedCount = 0
$deletedCount = 0
$errorCount = 0

foreach ($directory in $targetDirectories) {
    $processedCount++
    Write-Log "--- Processing Directory $processedCount of $($targetDirectories.Count) ---" -Level "INFO" -Color "Cyan"
    
    try {
        $fileCountBefore = 0
        if (Test-Path -Path $directory) {
            $fileCountBefore = (Get-ChildItem -Path $directory -File | Measure-Object).Count
            Write-Log "Files in directory before processing: $fileCountBefore" -Level "INFO" -Color "Gray"
        }
        
        Remove-OldestFile -DirectoryPath $directory
        
        if (Test-Path -Path $directory) {
            $fileCountAfter = (Get-ChildItem -Path $directory -File | Measure-Object).Count
            Write-Log "Files in directory after processing: $fileCountAfter" -Level "INFO" -Color "Gray"
            
            if ($fileCountAfter -lt $fileCountBefore) {
                $deletedCount++
            }
        }
    }
    catch {
        $errorCount++
        Write-Log "Unexpected error processing directory '$directory': $($_.Exception.Message)" -Level "ERROR" -Color "Red"
    }
    
    Write-Log "" -Level "INFO" -Color "White"
}

# Final summary
Write-Log "=== Script Execution Summary ===" -Level "INFO" -Color "Magenta"
Write-Log "Script completed at: $(Get-Date)" -Level "INFO" -Color "Magenta"
Write-Log "Total directories processed: $processedCount" -Level "INFO" -Color "White"
Write-Log "Files successfully deleted: $deletedCount" -Level "INFO" -Color "Green"
Write-Log "Errors encountered: $errorCount" -Level "INFO" -Color "Red"
Write-Log "Log file saved to: $logFilePath" -Level "INFO" -Color "Cyan"

# Optional: Pause to keep console window open
# Read-Host "Press Enter to exit"
