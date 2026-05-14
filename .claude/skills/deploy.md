# 自动部署

当用户说"部署"、"deploy"、"上线"时自动执行。

## 步骤
1. `bash scripts/deploy.sh`
2. 健康检查: `curl http://localhost:3001/api/health`
3. 飞书通知: `POST /api/feishu/notify/deploy`
4. 写入 Obsidian: `05-部署记录/`
5. 更新 memory/progress.md
