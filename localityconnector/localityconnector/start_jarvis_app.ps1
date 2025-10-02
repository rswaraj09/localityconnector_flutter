# PowerShell script to launch both the Jarvis API and Flutter app
Write-Host "Starting Jarvis application..." -ForegroundColor Cyan

# Check if Python is installed
try {
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python is not installed or not in PATH. Please install Python first." -ForegroundColor Red
    Read-Host -Prompt "Press Enter to exit"
    exit
}

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "Found Flutter" -ForegroundColor Green
} catch {
    Write-Host "Flutter is not installed or not in PATH. Please install Flutter first." -ForegroundColor Red
    Read-Host -Prompt "Press Enter to exit"
    exit
}

# Configuration - modify these paths as needed
$jarvisApiPath = Join-Path $PSScriptRoot "api"
$flutterAppPath = $PSScriptRoot

# Create a log directory if it doesn't exist
$logDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Start the Jarvis API server in a new window
Write-Host "Starting Jarvis API server on http://localhost:5000..." -ForegroundColor Yellow
$apiProcess = Start-Process -FilePath "python" -ArgumentList "app.py" -WorkingDirectory $jarvisApiPath -PassThru -WindowStyle Normal

# Wait for the API server to initialize
Write-Host "Waiting for API server to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start the Flutter app
Write-Host "Starting Flutter application..." -ForegroundColor Yellow
Set-Location $flutterAppPath

# Run on mobile device if connected, otherwise fallback to Windows
$devices = flutter devices
if ($devices -match "android" -or $devices -match "ios") {
    flutter run
} else {
    flutter run -d windows
}

# Handle cleanup when the script is terminated
$apiProcessId = $apiProcess.Id
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action {
    Write-Host "Cleaning up processes..." -ForegroundColor Yellow
    Stop-Process -Id $apiProcessId -Force -ErrorAction SilentlyContinue
}

Write-Host "Press Ctrl+C to exit and stop all processes" -ForegroundColor Cyan 