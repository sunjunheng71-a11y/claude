#!/bin/bash

# 启动所有服务脚本
# 一键启动前后端服务

set -e

echo "🚀 启动AI学习平台服务"
echo "========================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

# 检查后端是否已在运行
if netstat -ano | findstr :3001 > /dev/null; then
    echo "⚠️  后端服务已在运行"
    echo "🔄 停止现有服务..."
    taskkill /F /IM node.exe 2>nul
    sleep 2
fi

# 启动后端
echo "🚀 启动后端服务 (端口: 3001)..."
cd "$BACKEND_DIR"
nohup node index.js > "$BACKEND_DIR/logs/backend.log" 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$BACKEND_DIR/backend.pid"
echo "✅ 后端启动成功 (PID: $BACKEND_PID)"

# 启动前端开发服务器
echo "🚀 启动前端开发服务器 (端口: 5173)..."
cd "$FRONTEND_DIR"
nohup npm run dev > "$FRONTEND_DIR/logs/frontend.log" 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > "$FRONTEND_DIR/frontend.pid"
echo "✅ 前端开发服务器启动成功 (PID: $FRONTEND_PID)"

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 显示服务状态
echo ""
echo "📊 服务状态"
echo "========================"
echo "🔗 后端API: http://localhost:3001"
echo "🌐 前端开发: http://localhost:5173"
echo "📋 健康检查: http://localhost:3001/api/health"
echo ""
echo "📝 后端日志: tail -f $BACKEND_DIR/logs/backend.log"
echo "📝 前端日志: tail -f $FRONTEND_DIR/logs/frontend.log"
echo ""
echo "🛑 停止所有服务: bash $ROOT_DIR/scripts/stop-all.sh"
echo "🔧 监控服务: bash $ROOT_DIR/scripts/monitor.sh"

# 创建服务状态文件
echo "$(date '+%Y-%m-%d %H:%M:%S') - 服务启动 - 后端PID: $BACKEND_PID, 前端PID: $FRONTEND_PID" > "$ROOT_DIR/.services.running"

exit 0