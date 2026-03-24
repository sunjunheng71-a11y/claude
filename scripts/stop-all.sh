#!/bin/bash

# 停止所有服务脚本

echo "🛑 停止AI学习平台服务"
echo "========================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

# 停止后端服务
if netstat -ano | findstr :3001 > /dev/null; then
    echo "停止后端服务..."
    taskkill /F /IM node.exe 2>nul
    sleep 2
    echo "✅ 后端服务已停止"
else
    echo "ℹ️  后端服务未运行"
fi

# 停止前端开发服务器
if netstat -ano | findstr :5173 > /dev/null; then
    echo "停止前端开发服务器..."
    taskkill /F /IM vite.exe 2>nul
    sleep 1
    echo "✅ 前端开发服务器已停止"
else
    echo "ℹ️  前端开发服务器未运行"
fi

# 清理PID文件
[ -f "$BACKEND_DIR/backend.pid" ] && rm "$BACKEND_DIR/backend.pid"
[ -f "$FRONTEND_DIR/frontend.pid" ] && rm "$FRONTEND_DIR/frontend.pid"
[ -f "$ROOT_DIR/.services.running" ] && rm "$ROOT_DIR/.services.running"

echo ""
echo "✅ 所有服务已停止"
echo "💡 启动服务: bash $ROOT_DIR/scripts/start-all.sh"

exit 0