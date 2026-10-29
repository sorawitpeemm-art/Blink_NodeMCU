# Auto Upload Script for PlatformIO NodeMCU
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $projectRoot) { $projectRoot = (Get-Location).Path }

$pioPath = "$env:USERPROFILE\.platformio\penv\Scripts\platformio.exe"
if (-not (Test-Path $pioPath)) {
    $cmd = Get-Command "pio" -ErrorAction SilentlyContinue
    if ($cmd) {
        $pioPath = $cmd.Source
    } else {
        Write-Error "PlatformIO executable not found at $pioPath or in PATH."
        exit 1
    }
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Auto-Upload] Watching for changes in src/ ...   " -ForegroundColor Cyan
Write-Host " Edit and save your code to auto-compile & upload " -ForegroundColor Cyan
Write-Host " Press Ctrl+C in this terminal to stop.          " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $projectRoot
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Debounce tracker
$global:lastUploadTime = [DateTime]::MinValue
$debounceSeconds = 2

$onChange = {
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType

    # Filter only relevant source code and config files
    if ($path -match '\\src\\.*\.(cpp|c|h|hpp)$' -or $path -match 'platformio\.ini$') {
        $now = [DateTime]::Now
        if (($now - $global:lastUploadTime).TotalSeconds -ge $debounceSeconds) {
            $global:lastUploadTime = $now
            Write-Host "`n--------------------------------------------------" -ForegroundColor Yellow
            Write-Host "[$($now.ToString('HH:mm:ss'))] File changed: $name ($changeType)" -ForegroundColor Yellow
            Write-Host "Starting PlatformIO Upload..." -ForegroundColor Green
            Write-Host "--------------------------------------------------" -ForegroundColor Yellow
            
            & $pioPath run --target upload
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n>>> [SUCCESS] Upload completed successfully! <<<" -ForegroundColor Green
            } else {
                Write-Host "`n>>> [FAILED] Upload failed (Exit code: $LASTEXITCODE) <<<" -ForegroundColor Red
            }
            Write-Host "`n[Auto-Upload] Waiting for next file change..." -ForegroundColor Cyan
        }
    }
}

$subChanged = Register-ObjectEvent $watcher "Changed" -Action $onChange
$subCreated = Register-ObjectEvent $watcher "Created" -Action $onChange

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Unregister-Event -SourceIdentifier $subChanged.Name -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier $subCreated.Name -ErrorAction SilentlyContinue
    $watcher.Dispose()
    Write-Host "`n[Auto-Upload] Stopped watching." -ForegroundColor Yellow
}
