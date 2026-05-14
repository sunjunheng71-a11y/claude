@echo off
setlocal EnableExtensions
chcp 65001 >nul
title AI Platform - One-click Installer

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "LOG_DIR=%PROJECT_DIR%\logs"
set "BACKEND_DIR=%PROJECT_DIR%\backend"
set "ENV_FILE=%PROJECT_DIR%\.env"
set "DEFAULT_PORT=3001"

echo.
echo ========================================
echo   AI Platform - One-click Installer
echo ========================================
echo.
echo Project directory: %PROJECT_DIR%
echo.

call :requireAdmin || goto :fail
call :requireProjectLayout || goto :fail
call :ensureNode || goto :fail
call :installBackendDeps || goto :fail
call :installClaudeCode || goto :fail
call :writeEnvFile || goto :fail
call :startBackend || goto :fail

echo.
echo ========================================
echo   Install complete
echo ========================================
echo.
echo Project directory: %PROJECT_DIR%
echo Backend API: http://localhost:%DEFAULT_PORT%
echo Obsidian vault: %PROJECT_DIR%\obsidian
echo.
echo Next steps:
echo   1. Open a new PowerShell window
echo   2. Run: claude login
echo   3. Enter your API key when prompted
echo   4. Run: cd "%PROJECT_DIR%"
echo   5. Run: claude
echo.
echo Optional:
echo   - Edit .env and set FEISHU_WEBHOOK_URL to enable Feishu notifications
echo   - If port 3001 is busy, change PORT in .env
echo.
pause
exit /b 0

:requireAdmin
net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Please right-click install.bat and choose "Run as administrator".
    exit /b 1
)
echo [OK] Administrator permission confirmed
exit /b 0

:requireProjectLayout
if not exist "%BACKEND_DIR%\package.json" (
    echo [ERROR] backend\package.json was not found.
    echo Download ZIP from GitHub, extract it, then run this script from the extracted folder.
    exit /b 1
)
echo [OK] Project layout looks valid
exit /b 0

:ensureNode
echo.
echo [1/5] Checking Node.js...
where node >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=1" %%i in ('node -v') do echo   [OK] Node.js %%i
    exit /b 0
)

echo   [INFO] Node.js not found. Installing Node.js LTS...
where winget >nul 2>&1
if not errorlevel 1 (
    winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
) else (
    echo   [INFO] winget not found. Using Node.js MSI installer...
    curl.exe -L -o "%TEMP%\node-lts.msi" "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi"
    if errorlevel 1 exit /b 1
    msiexec /i "%TEMP%\node-lts.msi" /passive /norestart
)

call :refreshEnv
where node >nul 2>&1
if errorlevel 1 (
    echo   [ERROR] Node.js is still unavailable. Install it manually: https://nodejs.org
    exit /b 1
)

for /f "tokens=1" %%i in ('node -v') do echo   [OK] Node.js %%i
exit /b 0

:installBackendDeps
echo.
echo [2/5] Installing backend dependencies...
cd /d "%BACKEND_DIR%" || exit /b 1
call npm install
if errorlevel 1 (
    echo   [ERROR] npm install failed. Check your network and npm settings.
    exit /b 1
)
echo   [OK] Backend dependencies installed
exit /b 0

:installClaudeCode
echo.
echo [3/5] Installing Claude Code...
call npm install -g @anthropic-ai/claude-code
if errorlevel 1 (
    echo   [ERROR] Claude Code install failed. You can retry manually:
    echo   npm install -g @anthropic-ai/claude-code
    exit /b 1
)
echo   [OK] Claude Code installed
exit /b 0

:writeEnvFile
echo.
echo [4/5] Preparing .env...
if exist "%ENV_FILE%" (
    echo   [OK] .env already exists; leaving it unchanged
    exit /b 0
)

(
    echo NODE_ENV=development
    echo PORT=%DEFAULT_PORT%
    echo PROJECT_ROOT=%PROJECT_DIR%
    echo.
    echo # Feishu notifications ^(optional^)
    echo FEISHU_WEBHOOK_URL=
    echo FEISHU_APP_ID=
    echo FEISHU_APP_SECRET=
    echo FEISHU_VERIFY_TOKEN=
) > "%ENV_FILE%"

echo   [OK] .env created
exit /b 0

:startBackend
echo.
echo [5/5] Starting backend service...
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

cd /d "%BACKEND_DIR%" || exit /b 1
start "AI Platform Backend" /B cmd /c node index.js ^> "%LOG_DIR%\backend.log" 2^> "%LOG_DIR%\backend-error.log"
timeout /t 3 >nul

curl.exe -fsS "http://localhost:%DEFAULT_PORT%/api/health" >nul 2>&1
if errorlevel 1 (
    echo   [WARN] Backend may not have started.
    echo   Check log: %LOG_DIR%\backend.log
    echo   Error log: %LOG_DIR%\backend-error.log
    exit /b 0
)

echo   [OK] Backend started
exit /b 0

:refreshEnv
set "PATH=%PATH%;C:\Program Files\nodejs;%APPDATA%\npm;%LOCALAPPDATA%\Programs\Git\cmd"
exit /b 0

:fail
echo.
echo Install did not complete. Fix the error above and run this script again.
pause
exit /b 1
