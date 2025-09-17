# --- Logging Setup ---
$logFile = "D:\backup_script\backup_log.txt"
function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

# --- VPN Connection ---
$vpnName = "wel test"
$vpnUser = "test"
$vpnPass = "testing123"

Write-Log "Connecting to VPN..."
$vpnResult = rasdial $vpnName $vpnUser $vpnPass | Out-String
Write-Log "VPN output: $vpnResult"

if ($vpnResult -match "¤w³s½u" -or $vpnResult -match "¦¨¥\") {
    Write-Log "VPN connected."
} else {
    Write-Log "VPN connection failed. Output: $vpnResult Exiting script."
    exit
}

# --- Define Paths ---
$server1Dirs = @(
    "\\192.168.5.103\D$\SOFTEK_bk\acct2007",
    "\\192.168.5.103\D$\SOFTEK_bk\erp2012a",
    "\\192.168.5.103\D$\SOFTEK_bk\erp2012m",
    "\\192.168.5.103\D$\SOFTEK_bk\mf2007"
)
$backup1 = "D:\HUAHANbackup"
$backup2 = "D:\erp-backup"
$backup3 = "D:\HANSQLBackup"

# --- Server 1: Copy Latest File from Each Directory ---
Write-Log "Copying latest files from HuaHan 192.168.5.103..."
foreach ($dir in $server1Dirs) {
    if (Test-Path $dir) {
        $latest = Get-ChildItem -Path $dir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latest) {
            Copy-Item $latest.FullName -Destination $backup1
            Write-Log "Copied $($latest.Name) from $dir to $backup1"
        } else {
            Write-Log "No files found in $dir"
        }
    } else {
        Write-Log "Directory not found: $dir"
    }
}

# --- Server 2 & 3: Copy Files Created on Latest Date ---
function CopyFilesByLatestDate($sourcePath, $destPath) {
    if (Test-Path $sourcePath) {
        $files = Get-ChildItem -Path $sourcePath -File
        if ($files.Count -gt 0) {
            $latestDate = ($files | Sort-Object CreationTime -Descending | Select-Object -First 1).CreationTime.Date
            $filesToCopy = $files | Where-Object { $_.CreationTime.Date -eq $latestDate }
            foreach ($file in $filesToCopy) {
                Copy-Item $file.FullName -Destination $destPath
                Write-Log "Copied $($file.Name) from $sourcePath to $destPath"
            }
        } else {
            Write-Log "No files found in $sourcePath"
        }
    } else {
        Write-Log "Source path not found: $sourcePath"
    }
}

Write-Log "Copying files from ERP 192.168.5.105..."
CopyFilesByLatestDate "\\192.168.5.105\D$\SQL-Backup" $backup2

Write-Log "Copying files from Han-ERP 192.168.5.205..."
CopyFilesByLatestDate "\\192.168.5.205\D$\CHI-backup" $backup3

# --- Disconnect VPN ---
Write-Log "Disconnecting VPN..."
rasdial $vpnName /disconnect

Write-Log "All transfers complete."
