#!/bin/bash

# 环境设置脚本
# 设置AI学习平台开发环境

echo "🔧 AI学习平台环境设置"
echo "========================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 检查操作系统
echo "🖥️  检测操作系统..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="Windows"
else
    OS="未知"
fi
echo "  操作系统: $OS"

# 检查必要工具
echo "🔍 检查必要工具..."
MISSING_TOOLS=()

check_tool() {
    if ! command -v $1 >/dev/null 2>&1; then
        MISSING_TOOLS+=($1)
        echo "  ❌ $1: 未安装"
    else
        echo "  ✅ $1: 已安装 ($($1 --version 2>/dev/null | head -1))"
    fi
}

check_tool node
check_tool npm
check_tool git

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo ""
    echo "❌ 缺少必要工具: ${MISSING_TOOLS[*]}"

    if [ "$OS" = "Windows" ]; then
        echo "💡 Windows安装建议:"
        echo "  1. Node.js: 访问 https://nodejs.org 下载安装"
        echo "  2. Git: 访问 https://git-scm.com 下载安装"
        echo "  3. 安装后重启终端"
    elif [ "$OS" = "macOS" ]; then
        echo "💡 macOS安装建议:"
        echo "  1. 使用 Homebrew: brew install node git"
    elif [ "$OS" = "Linux" ]; then
        echo "💡 Linux安装建议:"
        echo "  1. Ubuntu/Debian: sudo apt install nodejs npm git"
        echo "  2. CentOS/RHEL: sudo yum install nodejs npm git"
    fi

    exit 1
fi

# 创建必要目录
echo ""
echo "📁 创建项目目录结构..."
mkdir -p "$ROOT_DIR/backend/logs"
mkdir -p "$ROOT_DIR/backend/public"
mkdir -p "$ROOT_DIR/frontend/logs"
mkdir -p "$ROOT_DIR/logs"

# 设置文件权限（Linux/macOS）
if [ "$OS" != "Windows" ]; then
    echo "🔒 设置脚本执行权限..."
    chmod +x "$ROOT_DIR/scripts/"*.sh
fi

# 安装全局工具（可选）
echo ""
echo "📦 安装可选全局工具..."
read -p "是否安装nodemon全局工具? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    npm install -g nodemon
    echo "✅ nodemon已安装"
fi

# 创建环境配置文件
echo ""
echo "⚙️  创建环境配置文件..."
cat > "$ROOT_DIR/.env.example" << EOF
# AI学习平台环境配置
NODE_ENV=development
PORT=3001
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:3001
QR_STORAGE_PATH=./backend/public
LOG_LEVEL=info

# 数据库配置 (可选)
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=ai_learning
# DB_USER=postgres
# DB_PASSWORD=your_password
EOF

cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
echo "✅ 环境配置文件已创建: $ROOT_DIR/.env"

# 安装项目依赖
echo ""
echo "📦 安装项目依赖..."
echo "安装后端依赖..."
cd "$ROOT_DIR/backend"
npm install

echo "安装前端依赖..."
cd "$ROOT_DIR/frontend"
npm install

# 创建Claude Code配置文件
echo ""
echo "🤖 创建Claude Code配置文件..."
mkdir -p "$ROOT_DIR/.claude"
cat > "$ROOT_DIR/.claude/config.json" << EOF
{
  "name": "AI Learning Platform",
  "description": "大学生AI学习平台 - 二维码生成与系统维护",
  "version": "1.0.0",
  "autoMode": true,
  "permissions": {
    "bash": ["npm", "git", "node", "docker"],
    "file": ["read", "write", "edit"],
    "network": ["api", "web"]
  },
  "hooks": {
    "pre-deploy": "bash scripts/setup-env.sh",
    "deploy": "bash scripts/deploy.sh",
    "post-deploy": "bash scripts/monitor.sh"
  }
}
EOF

echo "✅ Claude Code配置文件已创建: $ROOT_DIR/.claude/config.json"

# 输出完成信息
echo ""
echo "🎉 环境设置完成!"
echo "========================"
echo "📁 项目目录: $ROOT_DIR"
echo "🚀 启动服务: bash scripts/start-all.sh"
echo "📊 监控服务: bash scripts/monitor.sh"
echo "🔧 部署服务: bash scripts/deploy.sh"
echo ""
echo "🔗 重要链接:"
echo "  - 后端API: http://localhost:3001"
echo "  - 前端开发: http://localhost:5173"
echo "  - 健康检查: http://localhost:3001/api/health"
echo ""
echo "💡 下一步:"
echo "  1. 编辑 .env 文件配置环境变量"
echo "  2. 运行 bash scripts/start-all.sh 启动服务"
echo "  3. 访问 http://localhost:5173 查看前端"
echo ""
echo "🔄 如需重新设置环境，运行: bash scripts/setup-env.sh"

exit 0