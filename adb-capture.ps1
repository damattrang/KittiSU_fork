# KittiSU ADB Log Capture Script (PowerShell)
# Usage: .\adb-capture.ps1

$ADB = "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# Check if adb exists
if (-not (Test-Path $ADB)) {
    # Try common alternative paths
    $altPaths = @(
        "$env:ANDROID_HOME\platform-tools\adb.exe",
        "C:\platform-tools\adb.exe",
        "adb.exe"
    )
    foreach ($p in $altPaths) {
        if (Get-Command $p -ErrorAction SilentlyContinue) {
            $ADB = $p
            break
        }
    }
}

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  KittiSU ADB Log Capture" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check device connection
Write-Host "[1/4] Checking device connection..." -ForegroundColor Yellow
$devices = & $ADB devices 2>&1 | Select-String -Pattern "device$"
if (-not $devices) {
    Write-Host "ERROR: No device found! Connect phone via USB and enable USB Debugging." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Device found: $($devices.Line)" -ForegroundColor Green

# Clear logcat
Write-Host "[2/4] Clearing old logs..." -ForegroundColor Yellow
& $ADB logcat -c 2>&1 | Out-Null

# Prompt to reproduce crash
Write-Host "[3/4] Please REPRODUCE THE CRASH NOW on your phone." -ForegroundColor Yellow
Write-Host "  Open KittiSU app and wait for it to crash." -ForegroundColor White
Write-Host ""
Read-Host "Press Enter AFTER the app has crashed"

# Capture logs
Write-Host "[4/4] Capturing crash logs..." -ForegroundColor Yellow
$logFile = "$PSScriptRoot\kittisu-crash.log"

# Get full crash log
$crashLog = & $ADB logcat -d 2>&1
$crashLog | Out-File -FilePath $logFile -Encoding UTF8

# Filter relevant lines
$filtered = $crashLog | Select-String -Pattern "FATAL|AndroidRuntime|anhiutangerinee|kittisu|resukisu|kernelsu|CRASH|Exception|Error" -CaseSensitive:$false
$filtered | Out-File -FilePath "$PSScriptRoot\kittisu-crash-filtered.log" -Encoding UTF8

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  Logs saved:" -ForegroundColor Green
Write-Host "  Full:     $logFile" -ForegroundColor White
Write-Host "  Filtered: $PSScriptRoot\kittisu-crash-filtered.log" -ForegroundColor White
Write-Host "====================================" -ForegroundColor Cyan

# Show crash summary
Write-Host ""
Write-Host "Crash summary:" -ForegroundColor Yellow
$crashLine = $filtered | Select-String -Pattern "FATAL EXCEPTION|Process:.*kittisu" | Select-Object -First 5
if ($crashLine) {
    foreach ($line in $crashLine) {
        Write-Host "  $($line.Line)" -ForegroundColor Red
    }
} else {
    Write-Host "  No crash detected in logs. App may not have crashed?" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Filtered log content:" -ForegroundColor Yellow
Get-Content "$PSScriptRoot\kittisu-crash-filtered.log" | Select-Object -Last 30

Write-Host ""
Read-Host "Press Enter to exit"
