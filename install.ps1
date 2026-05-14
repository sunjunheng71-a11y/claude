param(
    [string]$InstallDir = "$env:USERPROFILE\ai-platform",
    [string]$RepoUrl = "https://github.com/sunjunheng71-a11y/claude.git",
    [int]$Port = 3001
)

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "AI Platform - PowerShell Installer"

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Refresh-Path {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

function Ensure-Command {
    param(
        [string]$Command,
        [string]$WingetId,
        [string]$FallbackUrl,
        [string]$FallbackFile,
        [string[]]$FallbackArgs
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "  [OK] $Command is available"
        return
    }

    Write-Host "  [INFO] $Command was not found. Installing..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install $WingetId --silent --accept-package-agreements --accept-source-agreements
    } else {
        $target = Join-Path $env:TEMP $FallbackFile
        Invoke-WebRequest -Uri $FallbackUrl -OutFile $target
        Start-Process -Wait -FilePath $target -ArgumentList $FallbackArgs
    }

    Refresh-Path
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "$Command is still unavailable after installation"
    }
}

Write-Host "`n=== AI Platform - PowerShell Installer ===`n" -ForegroundColor Cyan

if (-not (Test-Admin)) {
    throw "Run PowerShell as Administrator, then execute this script again."
}

Write-Step "[1/7] Check Node.js"
Ensure-Command `
    -Command "node" `
    -WingetId "OpenJS.NodeJS.LTS" `
    -FallbackUrl "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi" `
    -FallbackFile "node-lts.msi" `
    -FallbackArgs @("/i", "`"$env:TEMP\node-lts.msi`"", "/passive", "/norestart")

Write-Step "[2/7] Check Git"
Ensure-Command `
    -Command "git" `
    -WingetId "Git.Git" `
    -FallbackUrl "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe" `
    -FallbackFile "git-installer.exe" `
    -FallbackArgs @("/VERYSILENT", "/NORESTART")

Write-Step "[3/7] Install Claude Code"
npm install -g @anthropic-ai/claude-code
Write-Host "  [OK] Claude Code installed"

Write-Step "[4/7] Download or update project"
if (Test-Path (Join-Path $InstallDir ".git")) {
    Set-Location $InstallDir
    git pull origin main
    Write-Host "  [OK] Project updated: $InstallDir"
} else {
    if (Test-Path $InstallDir) {
        $hasFiles = Get-ChildItem $InstallDir -Force -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hasFiles) {
            throw "Install directory already exists and is not empty: $InstallDir. Choose another path or clean it manually."
        }
    }
    git clone $RepoUrl $InstallDir
    Write-Host "  [OK] Project downloaded: $InstallDir"
}

Write-Step "[5/7] Install backend dependencies"
$backendDir = Join-Path $InstallDir "backend"
if (-not (Test-Path (Join-Path $backendDir "package.json"))) {
    throw "backend\package.json is missing. The project checkout is incomplete."
}
Set-Location $backendDir
npm install
Write-Host "  [OK] Backend dependencies installed"

Write-Step "[6/7] Prepare .env"
$envFile = Join-Path $InstallDir ".env"
if (-not (Test-Path $envFile)) {
    @"
NODE_ENV=development
PORT=$Port
PROJECT_ROOT=$InstallDir

# Feishu notifications (optional)
FEISHU_WEBHOOK_URL=
FEISHU_APP_ID=
FEISHU_APP_SECRET=
FEISHU_VERIFY_TOKEN=
"@ | Set-Content -Path $envFile -Encoding UTF8
    Write-Host "  [OK] .env created"
} else {
    Write-Host "  [OK] .env already exists; leaving it unchanged"
}

Write-Step "[7/7] Start backend service"
$logDir = Join-Path $InstallDir "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
Set-Location $backendDir

$stdout = Join-Path $logDir "backend.log"
$stderr = Join-Path $logDir "backend-error.log"
Start-Process -NoNewWindow -FilePath "node" -ArgumentList "index.js" -RedirectStandardOutput $stdout -RedirectStandardError $stderr
Start-Sleep -Seconds 3

try {
    Invoke-RestMethod -Uri "http://localhost:$Port/api/health" -TimeoutSec 3 | Out-Null
    Write-Host "  [OK] Backend started: http://localhost:$Port" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Backend may not have started. Check logs:" -ForegroundColor Yellow
    Write-Host "    $stdout"
    Write-Host "    $stderr"
}

Write-Host "`n=== Install complete ===" -ForegroundColor Cyan
Write-Host "Project directory: $InstallDir"
Write-Host "Backend API: http://localhost:$Port"
Write-Host "Next steps:"
Write-Host "  1. Open a new PowerShell window"
Write-Host "  2. Run claude login and enter your API key"
Write-Host "  3. Run cd `"$InstallDir`""
Write-Host "  4. Run claude"
