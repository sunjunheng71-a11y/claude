@echo off
chcp 65001 >nul
title AI全自动开发平台 - 安装

echo.
echo ========================================
echo   AI 全自动开发平台 - 安装
echo ========================================
echo.

:: 以 install.bat 所在目录作为项目目录
set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
echo 项目目录: %PROJECT_DIR%

:: 管理员权限检查
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 需要管理员权限，右键选"以管理员身份运行"
    pause
    exit /b 1
)

:: ========== 1. Node.js ==========
echo.
echo [1/5] 检查 Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=1" %%i in ('node -v') do echo   [OK] %%i
) else (
    echo   [X] 未安装，正在自动安装...
    winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>nul
    if %errorlevel% neq 0 (
        curl -L -o "%TEMP%\node.msi" "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi"
        msiexec /i "%TEMP%\node.msi" /passive /norestart
    )
    call :refreshEnv
    where node >nul 2>&1
    if %errorlevel% neq 0 (
        echo   [X] Node.js 安装失败
        echo   请手动去 https://nodejs.org 下载安装
        pause
        exit /b 1
    )
    echo   [OK] 安装完成
)

:: ========== 2. 安装项目依赖 ==========
echo.
echo [2/5] 安装项目依赖...
cd /d "%PROJECT_DIR%\backend"
call npm install
echo   [OK]

:: ========== 3. 安装 Claude Code ==========
echo.
echo [3/5] 安装 Claude Code...
call npm install -g @anthropic-ai/claude-code 2>nul
if %errorlevel% equ 0 (
    echo   [OK]
) else (
    echo   [X] 安装失败，检查网络后手动运行:
    echo   npm install -g @anthropic-ai/claude-code
)

:: ========== 4. .env 配置 ==========
echo.
echo [4/5] 配置文件...
if not exist "%PROJECT_DIR%\.env" (
    (
        echo NODE_ENV=development
        echo PORT=3001
        echo PROJECT_ROOT=%PROJECT_DIR%
        echo.
        echo # 飞书通知（可选）
        echo FEISHU_WEBHOOK_URL=
        echo FEISHU_APP_ID=
        echo FEISHU_APP_SECRET=
        echo FEISHU_VERIFY_TOKEN=
    ) > "%PROJECT_DIR%\.env"
    echo   [OK] 已创建 .env
) else (
    echo   [OK] .env 已存在
)

:: ========== 5. 创建必要目录并启动 ==========
echo.
echo [5/5] 启动后端...
if not exist "%PROJECT_DIR%\logs" mkdir "%PROJECT_DIR%\logs"

cd /d "%PROJECT_DIR%\backend"
start /B node index.js > "%PROJECT_DIR%\logs\backend.log" 2>&1
timeout /t 3 >nul

curl -s http://localhost:3001/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] 服务已启动
) else (
    echo   [X] 服务可能未启动，查看 logs\backend.log
)

:: ========== 完成 ==========
echo.
echo ========================================
echo   安装完成
echo ========================================
echo.
echo   项目目录: %PROJECT_DIR%
echo   后端API:  http://localhost:3001
echo.
echo   【必做】设置 DeepSeek API Key:
echo   打开 PowerShell，输入:
echo     claude login
echo   按提示填入你的 DeepSeek API Key
echo   （API Key 获取: platform.deepseek.com）
echo.
echo   登录后，在项目目录下输入 claude 开始:
echo     cd %PROJECT_DIR%
echo     claude
echo.
echo   可选: 编辑 .env 配置飞书通知
echo   Obsidian 笔记: %PROJECT_DIR%\obsidian
echo ========================================
echo.
pause
exit /b 0

:: ========== 刷新环境变量 ==========
:refreshEnv
    set "PATH=%PATH%;C:\Program Files\nodejs;%APPDATA%\npm;%LOCALAPPDATA%\Programs\Git\cmd"
    goto :eof
