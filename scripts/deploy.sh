#!/bin/bash
# 全自动部署脚本
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
DEPLOY_TIME=$(date '+%Y-%m-%d %H:%M:%S')

echo "[deploy] 开始 - $DEPLOY_TIME"

# 1. 检查依赖
command -v node >/dev/null 2>&1 || { echo "[deploy] Node.js 未安装"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "[deploy] npm 未安装"; exit 1; }

# 2. Git 更新
if [ -d "$ROOT_DIR/.git" ]; then
    echo "[deploy] 拉取最新代码..."
    cd "$ROOT_DIR"
    git pull origin main 2>/dev/null || echo "[deploy] Git pull 跳过"
fi

# 3. 安装后端依赖
echo "[deploy] 安装依赖..."
cd "$BACKEND_DIR"
npm install --silent

# 4. 创建目录
mkdir -p "$BACKEND_DIR/public" "$BACKEND_DIR/logs" "$ROOT_DIR/logs"

# 5. 重启服务
echo "[deploy] 重启后端服务..."
pkill -f "node.*index.js" 2>/dev/null || true
sleep 1

cd "$BACKEND_DIR"
nohup node index.js > "$BACKEND_DIR/logs/backend.log" 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$BACKEND_DIR/backend.pid"

sleep 3

# 6. 健康检查
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health 2>/dev/null || echo "000")

if [ "$HEALTH_CHECK" = "200" ]; then
    echo "[deploy] 健康检查通过"
    DEPLOY_STATUS="success"
else
    echo "[deploy] 健康检查失败 HTTP=$HEALTH_CHECK"
    DEPLOY_STATUS="failed"
fi

# 7. 保存部署记录
echo "$DEPLOY_TIME - 部署$DEPLOY_STATUS - PID: $BACKEND_PID" >> "$ROOT_DIR/logs/deployments.log"

# 8. 飞书通知
if [ -n "$FEISHU_WEBHOOK_URL" ] || [ "$FEISHU_WEBHOOK_URL" != "" ]; then
    curl -s -X POST "http://localhost:3001/api/feishu/notify/deploy" \
        -H "Content-Type: application/json" \
        -d "{\"version\":\"$DEPLOY_TIME\",\"health\":\"$HEALTH_CHECK\",\"changes\":\"自动部署\"}" \
        > /dev/null 2>&1 || true
fi

# 9. Obsidian 部署笔记
curl -s -X POST "http://localhost:3001/api/obsidian/write" \
    -H "Content-Type: application/json" \
    -d "{\"folder\":\"05-部署记录\",\"title\":\"部署 $DEPLOY_TIME\",\"content\":\"## 信息\\n- 版本: $DEPLOY_TIME\\n- 状态: $DEPLOY_STATUS\\n- PID: $BACKEND_PID\\n- 健康检查: HTTP $HEALTH_CHECK\",\"meta\":{\"type\":\"部署\",\"status\":\"已完成\",\"tags\":[\"deploy\"]}}" \
    > /dev/null 2>&1 || true

echo "[deploy] 完成 http://localhost:3001"
exit 0
