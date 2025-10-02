# PowerShell script to launch both the Jarvis API and Flutter app
Write-Host "Starting Jarvis application..." -ForegroundColor Cyan

# Configuration
$projectRoot = $PSScriptRoot
$apiPath = Join-Path $projectRoot "api"

# Start the Jarvis API server in a new window
Write-Host "Starting Jarvis API server on http://localhost:5000..." -ForegroundColor Yellow
$apiProcess = Start-Process -FilePath "python" -ArgumentList "app.py" -WorkingDirectory $apiPath -PassThru -WindowStyle Normal

# Wait for the API server to initialize
Write-Host "Waiting for API server to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start the Flutter app
Write-Host "Starting Flutter application..." -ForegroundColor Yellow
Set-Location $projectRoot

# Run Flutter app - detect connected devices or run on Windows
$devices = flutter devices
if ($devices -match "android" -or $devices -match "ios") {
    flutter run
} else {
    flutter run -d windows
}

# Clean up when script is terminated
$apiProcessId = $apiProcess.Id
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action {
    Write-Host "Cleaning up processes..." -ForegroundColor Yellow
    Stop-Process -Id $apiProcessId -Force -ErrorAction SilentlyContinue
}

Write-Host "Press Ctrl+C to exit and stop all processes" -ForegroundColor Cyan 