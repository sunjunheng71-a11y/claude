#!/bin/bash

# 重启所有服务脚本

echo "🔄 重启AI学习平台服务"
echo "========================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 停止服务
if [ -f "$ROOT_DIR/scripts/stop-all.sh" ]; then
    bash "$ROOT_DIR/scripts/stop-all.sh"
else
    echo "⚠️  停止脚本不存在，强制停止进程..."
    pkill -f "node.*index.js" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true
    sleep 2
fi

# 等待清理
sleep 2

# 启动服务
if [ -f "$ROOT_DIR/scripts/start-all.sh" ]; then
    bash "$ROOT_DIR/scripts/start-all.sh"
else
    echo "❌ 启动脚本不存在"
    exit 1
fi

echo "✅ 服务重启完成"
exit 0