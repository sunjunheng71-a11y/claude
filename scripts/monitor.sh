#!/bin/bash

# 系统监控脚本
# 监控服务状态、资源使用情况

set -e

echo "📈 AI学习平台监控面板"
echo "========================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"

# 检查后端是否运行
if ! netstat -ano | findstr :3001 > /dev/null; then
    echo "❌ 后端服务未运行"
    echo "💡 启动服务: bash $ROOT_DIR/scripts/start-all.sh"
    exit 1
fi

# 获取后端PID (Windows下从netstat获取)
BACKEND_PID=$(netstat -ano | findstr :3001 | awk '{print $5}' | head -1)
echo "🔧 后端服务端口: 3001 (PID: ${BACKEND_PID:-未知})"

# 1. 健康检查
echo ""
echo "🏥 健康检查"
echo "----------"
HEALTH_RESPONSE=$(curl -s -w "\nHTTP状态码: %{http_code}" http://localhost:3001/api/health || echo "连接失败")
echo "$HEALTH_RESPONSE"

# 2. 系统信息
echo ""
echo "🖥️  系统信息"
echo "----------"
SYS_INFO=$(curl -s http://localhost:3001/api/system-info 2>/dev/null || echo "无法获取系统信息")
if [ "$SYS_INFO" != "无法获取系统信息" ]; then
    echo "$SYS_INFO" | grep -E "(platform|hostname|uptime|nodeVersion|cpus)" | sed 's/["{},]//g' | sed 's/^/  /'
fi

# 3. 监控数据
echo ""
echo "📊 资源监控"
echo "----------"
MONITOR_DATA=$(curl -s http://localhost:3001/api/monitor 2>/dev/null || echo "无法获取监控数据")
if [ "$MONITOR_DATA" != "无法获取监控数据" ]; then
    echo "内存使用:"
    echo "$MONITOR_DATA" | grep -A4 '"memory"' | sed 's/["{},]//g' | sed 's/^/  /'
    echo "服务运行时间: $(echo "$MONITOR_DATA" | grep '"uptime"' | sed 's/.*: //' | sed 's/,//') 秒"
fi

# 4. 进程资源使用
echo ""
echo "⚙️  进程资源"
echo "----------"
if command -v ps >/dev/null 2>&1; then
    ps -p $BACKEND_PID -o pid,ppid,%cpu,%mem,cmd --no-headers | awk '{printf "  PID: %s, CPU: %s%%, 内存: %s%%, 命令: %s\n", $1, $3, $4, $5}'
fi

# 5. 磁盘使用
echo ""
echo "💾 磁盘空间"
echo "----------"
df -h . | tail -1 | awk '{printf "  可用: %s, 已用: %s, 使用率: %s\n", $4, $3, $5}'

# 6. 日志文件大小
echo ""
echo "📝 日志文件"
echo "----------"
if [ -f "$BACKEND_DIR/logs/backend.log" ]; then
    LOG_SIZE=$(du -h "$BACKEND_DIR/logs/backend.log" | cut -f1)
    echo "  后端日志: $BACKEND_DIR/logs/backend.log ($LOG_SIZE)"
    echo "  最后10行日志:"
    tail -10 "$BACKEND_DIR/logs/backend.log" | sed 's/^/    /'
else
    echo "  后端日志文件不存在"
fi

# 7. 二维码生成统计
echo ""
echo "🔗 二维码服务"
echo "----------"
PUBLIC_DIR="$BACKEND_DIR/public"
if [ -d "$PUBLIC_DIR" ]; then
    QR_COUNT=$(find "$PUBLIC_DIR" -name "qr_*.png" 2>/dev/null | wc -l)
    echo "  已生成二维码: $QR_COUNT 个"

    if [ $QR_COUNT -gt 0 ]; then
        LATEST_QR=$(find "$PUBLIC_DIR" -name "qr_*.png" -printf "%T+ %p\n" | sort -r | head -1 | cut -d' ' -f2-)
        LATEST_SIZE=$(du -h "$LATEST_QR" 2>/dev/null | cut -f1 || echo "未知")
        echo "  最新二维码: $(basename "$LATEST_QR") ($LATEST_SIZE)"
    fi
else
    echo "  二维码目录不存在"
fi

echo ""
echo "========================"
echo "🔄 刷新监控: bash $ROOT_DIR/scripts/monitor.sh"
echo "🚀 重启服务: bash $ROOT_DIR/scripts/restart.sh"
echo "📊 详细监控: 访问 http://localhost:3001/api/monitor"
echo "🕐 当前时间: $(date '+%Y-%m-%d %H:%M:%S')"

exit 0