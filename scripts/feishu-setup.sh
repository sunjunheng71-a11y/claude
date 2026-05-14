#!/bin/bash
# 飞书 Bot 配置引导

echo "=== 飞书 Bot 配置 ==="
echo ""
echo "你需要在飞书开放平台创建一个 Bot:"
echo ""
echo "1. 打开 https://open.feishu.cn"
echo "2. 创建企业自建应用"
echo "3. 获取 App ID 和 App Secret"
echo "4. 在「事件订阅」中配置回调地址: http://你的IP:3001/api/feishu/callback"
echo "5. 添加「im:message」和「im:message:send」权限"
echo "6. 或者直接在飞书群添加「群机器人」，复制 Webhook URL"
echo ""

read -p "飞书 Webhook URL（推荐，直接填）: " webhook
read -p "飞书 App ID（可选）: " appId
read -p "飞书 App Secret（可选）: " appSecret
read -p "Verify Token（可选）: " verifyToken

# 写入 .env
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    # 用 sed 更新
    sed -i "s|FEISHU_WEBHOOK_URL=.*|FEISHU_WEBHOOK_URL=$webhook|" "$ENV_FILE" 2>/dev/null || true
    sed -i "s|FEISHU_APP_ID=.*|FEISHU_APP_ID=$appId|" "$ENV_FILE" 2>/dev/null || true
    sed -i "s|FEISHU_APP_SECRET=.*|FEISHU_APP_SECRET=$appSecret|" "$ENV_FILE" 2>/dev/null || true
    sed -i "s|FEISHU_VERIFY_TOKEN=.*|FEISHU_VERIFY_TOKEN=$verifyToken|" "$ENV_FILE" 2>/dev/null || true
    echo "[OK] .env 已更新"
else
    echo "[!] .env 文件不存在，请先在项目目录创建"
fi

echo ""
echo "配置完成。重启后端服务使配置生效:"
echo "  bash scripts/restart.sh"
