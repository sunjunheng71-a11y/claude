@echo off
chcp 65001 >nul
title AI全自动开发平台 - 安装

echo.
echo ========================================
echo   AI 全自动开发平台 - 安装
echo ========================================
echo.

:: 管理员权限检查
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 需要管理员权限，右键选"以管理员身份运行"
    pause
    exit /b 1
)

set "INSTALL_DIR=%USERPROFILE%\ai-platform"
set "REPO_URL=https://github.com/sunjunheng71-a11y/claude.git"

:: ========== 1. Node.js ==========
echo [1/7] Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] %node --version%
) else (
    echo   [!] 未安装，正在通过 winget 自动安装...
    winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>nul
    if %errorlevel% neq 0 (
        echo   [!] winget 失败，正在下载安装包...
        curl -L -o "%TEMP%\node.msi" "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi"
        msiexec /i "%TEMP%\node.msi" /passive /norestart
    )
    :: 刷新 PATH
    call :refreshPath
    where node >nul 2>&1 || (echo [!] Node.js 安装失败，请手动安装 && pause && exit /b 1)
    echo   [OK] Node.js 安装完成
)

:: ========== 2. Git ==========
echo [2/7] Git...
where git >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%i in ('git --version') do echo   [OK] Git %%i
) else (
    echo   [!] 未安装，正在通过 winget 自动安装...
    winget install Git.Git --silent --accept-package-agreements 2>nul
    if %errorlevel% neq 0 (
        echo   [!] winget 失败，正在下载安装包...
        curl -L -o "%TEMP%\git.exe" "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe"
        "%TEMP%\git.exe" /VERYSILENT /NORESTART
    )
    call :refreshPath
    where git >nul 2>&1 || (echo [!] Git 安装失败，请手动安装 && pause && exit /b 1)
    echo   [OK] Git 安装完成
)

:: ========== 3. Claude Code ==========
echo [3/7] Claude Code...
call npm install -g @anthropic-ai/claude-code 2>nul
if %errorlevel% equ 0 (
    echo   [OK]
) else (
    echo   [!] Claude Code 安装失败，跳过（可稍后手动装）
)

:: ========== 4. ccswith ==========
echo [4/7] ccswith...
if exist "%USERPROFILE%\.cc-switch\" (
    echo   [OK] 已配置
) else (
    echo   [i]  未检测到 ccswith，如需使用请手动下载配置
)

:: ========== 5. 克隆项目 ==========
echo [5/7] 项目代码...
if exist "%INSTALL_DIR%\.git" (
    echo   [OK] 已存在，拉取最新...
    cd /d "%INSTALL_DIR%"
    git pull origin main 2>nul
) else (
    if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
    git clone "%REPO_URL%" "%INSTALL_DIR%"
    echo   [OK] 克隆完成
)
cd /d "%INSTALL_DIR%"

:: ========== 6. npm install ==========
echo [6/7] 安装依赖...
cd /d "%INSTALL_DIR%\backend"
call npm install
echo   [OK]

:: ========== 7. .env ==========
echo [7/7] 配置文件...
if not exist "%INSTALL_DIR%\.env" (
    (
        echo NODE_ENV=development
        echo PORT=3001
        echo PROJECT_ROOT=%INSTALL_DIR%
        echo FEISHU_APP_ID=
        echo FEISHU_APP_SECRET=
        echo FEISHU_WEBHOOK_URL=
        echo FEISHU_VERIFY_TOKEN=
    ) > "%INSTALL_DIR%\.env"
    echo   [OK] 已创建 .env
) else (
    echo   [OK] .env 已存在
)

:: ========== 启动后端 ==========
echo.
echo 启动后端服务...
cd /d "%INSTALL_DIR%\backend"
start /B node index.js > "%INSTALL_DIR%\logs\backend.log" 2>&1
timeout /t 2 >nul

curl -s http://localhost:3001/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 服务已启动 http://localhost:3001
) else (
    echo [!] 服务可能未启动，查看: %INSTALL_DIR%\logs\backend.log
)

echo.
echo ========================================
echo   完成
echo ========================================
echo   项目: %INSTALL_DIR%
echo   服务: http://localhost:3001
echo   用法: 终端输入 claude 开始
echo   笔记: %INSTALL_DIR%\obsidian
echo ========================================
pause
exit /b 0

:: ========== 刷新 PATH ==========
:refreshPath
    set "PATH=%PATH%;C:\Program Files\nodejs;C:\Program Files\Git\cmd;%LOCALAPPDATA%\Programs\Git\cmd"
    goto :eof
