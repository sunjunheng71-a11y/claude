#!/bin/bash
# 系统监控脚本
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MONITOR_TIME=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== 系统监控 - $MONITOR_TIME ==="

# 1. 健康检查
HEALTH=$(curl -s -w "\n%{http_code}" http://localhost:3001/api/health 2>/dev/null || echo "连接失败")
HTTP_CODE=$(echo "$HEALTH" | tail -1)

if [ "$HTTP_CODE" != "200" ]; then
    echo "[ALERT] 服务不可用 HTTP=$HTTP_CODE"
    curl -s -X POST "http://localhost:3001/api/feishu/notify/alert" \
        -H "Content-Type: application/json" \
        -d "{\"level\":\"error\",\"title\":\"服务离线\",\"content\":\"$MONITOR_TIME 健康检查失败 HTTP=$HTTP_CODE\"}" \
        > /dev/null 2>&1 || true
else
    echo "[OK] 健康检查 HTTP $HTTP_CODE"
fi

# 2. 系统资源
echo "--- 系统资源 ---"
curl -s http://localhost:3001/api/monitor 2>/dev/null || echo "无法获取"

# 3. 端口检查
echo "--- 服务 ---"
netstat -ano 2>/dev/null | findstr :3001 > /dev/null && echo "[OK] 后端 port 3001" || echo "[!!] 后端未运行"

# 4. Obsidian 统计
echo "--- Obsidian ---"
curl -s http://localhost:3001/api/obsidian/stats 2>/dev/null || echo "无法获取"

echo "--- $MONITOR_TIME ---"
exit 0
