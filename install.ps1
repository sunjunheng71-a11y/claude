# AI全自动开发平台 - PowerShell 安装
# 用法: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "AI全自动开发平台 - 安装"

$INSTALL_DIR = "$env:USERPROFILE\ai-platform"
$REPO_URL = "https://github.com/sunjunheng71-a11y/claude.git"

Write-Host "`n=== AI 全自动开发平台 - 安装 ===`n" -ForegroundColor Cyan

# 检查管理员
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[!] 需要管理员权限" -ForegroundColor Red
    exit 1
}

# 1. Node.js
Write-Host "[1/7] Node.js..." -ForegroundColor Green
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] $(node --version)"
} else {
    Write-Host "  [!] 未安装，自动安装中..."
    try {
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements
    } catch {
        Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi" -OutFile "$env:TEMP\node.msi"
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$env:TEMP\node.msi`" /passive /norestart"
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 2. Git
Write-Host "[2/7] Git..." -ForegroundColor Green
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] $(git --version)"
} else {
    Write-Host "  [!] 未安装，自动安装中..."
    try {
        winget install Git.Git --silent --accept-package-agreements
    } catch {
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe" -OutFile "$env:TEMP\git.exe"
        Start-Process -Wait -FilePath "$env:TEMP\git.exe" -ArgumentList "/VERYSILENT /NORESTART"
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 3. Claude Code
Write-Host "[3/7] Claude Code..." -ForegroundColor Green
try { npm install -g @anthropic-ai/claude-code; Write-Host "  [OK]" } catch { Write-Host "  [!] 安装失败: $_" }

# 4. ccswith
Write-Host "[4/7] ccswith..." -ForegroundColor Green
if (Test-Path "$env:USERPROFILE\.cc-switch\") { Write-Host "  [OK] 已配置" } else { Write-Host "  [i] 未检测到" }

# 5. 克隆
Write-Host "[5/7] 项目代码..." -ForegroundColor Green
if (Test-Path "$INSTALL_DIR\.git") {
    Set-Location $INSTALL_DIR
    git pull origin main 2>$null
    Write-Host "  [OK] 已更新"
} else {
    New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
    git clone $REPO_URL $INSTALL_DIR
    Write-Host "  [OK] 克隆完成"
}

# 6. npm install
Write-Host "[6/7] 依赖..." -ForegroundColor Green
Set-Location "$INSTALL_DIR\backend"
npm install | Out-Null
Write-Host "  [OK]"

# 7. .env
Write-Host "[7/7] 配置..." -ForegroundColor Green
Set-Location $INSTALL_DIR
if (-not (Test-Path ".env")) {
    @"
NODE_ENV=development
PORT=3001
PROJECT_ROOT=$INSTALL_DIR
FEISHU_APP_ID=
FEISHU_APP_SECRET=
FEISHU_WEBHOOK_URL=
FEISHU_VERIFY_TOKEN=
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "  [OK] 已创建 .env"
} else { Write-Host "  [OK] .env 已存在" }

# 启动
Write-Host "`n启动后端..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$INSTALL_DIR\logs" | Out-Null
Set-Location "$INSTALL_DIR\backend"
Start-Process -NoNewWindow node -ArgumentList "index.js" -RedirectStandardOutput "$INSTALL_DIR\logs\backend.log" -RedirectStandardError "$INSTALL_DIR\logs\backend-error.log"
Start-Sleep 2

try {
    Invoke-RestMethod -Uri "http://localhost:3001/api/health" -TimeoutSec 3 | Out-Null
    Write-Host "[OK] 服务已启动 http://localhost:3001" -ForegroundColor Green
} catch {
    Write-Host "[!] 服务可能未启动: $INSTALL_DIR\logs\backend.log" -ForegroundColor Yellow
}

Write-Host "`n=== 完成 ===" -ForegroundColor Cyan
Write-Host "项目: $INSTALL_DIR"
Write-Host "用法: claude"
Write-Host "笔记: $INSTALL_DIR\obsidian`n"
