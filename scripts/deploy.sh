#!/bin/bash

# 全自动部署脚本
# 作者: Claude全自动Agent
# 功能: 一键部署前后端服务

set -e  # 遇到错误立即退出

echo "🚀 开始全自动部署流程"
echo "========================"

# 项目根目录
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
BACKEND_DIR="$ROOT_DIR/backend"

echo "📁 项目根目录: $ROOT_DIR"

# 1. 检查依赖
echo "🔍 检查系统依赖..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js未安装"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm未安装"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "❌ Git未安装"; exit 1; }

echo "✅ 依赖检查通过"
echo "Node版本: $(node --version)"
echo "npm版本: $(npm --version)"
echo "Git版本: $(git --version)"

# 2. 更新代码（如果是从git仓库）
if [ -d "$ROOT_DIR/.git" ]; then
    echo "📥 更新代码库..."
    git pull origin main
fi

# 3. 安装前端依赖并构建
echo "⚙️  构建前端应用..."
cd "$FRONTEND_DIR"
echo "安装前端依赖..."
npm install --silent
echo "构建前端..."
npm run build

# 4. 安装后端依赖
echo "⚙️  设置后端服务..."
cd "$BACKEND_DIR"
echo "安装后端依赖..."
npm install --silent

# 5. 创建必要目录
echo "📁 创建必要目录..."
mkdir -p "$BACKEND_DIR/public"
mkdir -p "$BACKEND_DIR/logs"

# 6. 启动服务
echo "🚀 启动后端服务..."
# 检查是否已有进程在运行
if pgrep -f "node.*index.js" > /dev/null; then
    echo "🔄 重启后端服务..."
    pkill -f "node.*index.js"
fi

# 启动后端服务（后台运行）
cd "$BACKEND_DIR"
nohup node index.js > "$BACKEND_DIR/logs/backend.log" 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$BACKEND_DIR/backend.pid"
echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"

# 7. 等待服务就绪
echo "⏳ 等待服务就绪..."
sleep 3

# 8. 健康检查
echo "🏥 执行健康检查..."
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health || true)

if [ "$HEALTH_CHECK" = "200" ]; then
    echo "✅ 服务健康检查通过"

    # 获取系统信息
    SYSTEM_INFO=$(curl -s http://localhost:3001/api/system-info | python -m json.tool 2>/dev/null || curl -s http://localhost:3001/api/system-info)
    echo "📊 系统信息:"
    echo "$SYSTEM_INFO" | grep -E "(platform|hostname|nodeVersion)" || true
else
    echo "⚠️  健康检查失败 (HTTP $HEALTH_CHECK)"
    echo "📄 查看日志: $BACKEND_DIR/logs/backend.log"
fi

# 9. 输出部署结果
echo ""
echo "🎉 部署完成!"
echo "========================"
echo "📊 后端API: http://localhost:3001"
echo "🔗 健康检查: http://localhost:3001/api/health"
echo "📱 二维码生成: POST http://localhost:3001/api/generate-qr"
echo "🖥️  系统监控: http://localhost:3001/api/monitor"
echo ""
echo "📁 前端构建目录: $FRONTEND_DIR/dist"
echo "📝 后端日志: $BACKEND_DIR/logs/backend.log"
echo "🔄 重启服务: bash $ROOT_DIR/scripts/restart.sh"
echo "📈 监控服务: bash $ROOT_DIR/scripts/monitor.sh"
echo ""
echo "💡 提示: 前端应用需要单独部署到Web服务器或使用nginx代理"
echo "========================"

# 10. 保存部署记录
DEPLOY_LOG="$ROOT_DIR/logs/deployments.log"
mkdir -p "$ROOT_DIR/logs"
echo "$(date '+%Y-%m-%d %H:%M:%S') - 部署成功 - 后端PID: $BACKEND_PID" >> "$DEPLOY_LOG"

exit 0