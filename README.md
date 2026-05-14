# AI 全自动开发平台

给**编程零基础的人**用的 AI 开发助手。

终端里跟 AI 聊天，它帮你写代码、跑测试、部署上线。自动记录笔记到 Obsidian，飞书通知进度。

## 安装

1. 下载项目
2. 右键 `install.bat` → 以管理员身份运行
3. 等待完成

## 使用

打开 PowerShell / 终端：

```bash
claude
```

跟 AI 聊天就行：

- "帮我创建一个网页"
- "部署到服务器"
- "修一下这个 bug"
- "项目现在什么状态"

AI 会自动开发、测试、部署，过程记录到 `obsidian/`。

## 结构

```
├── backend/          # 后端 API（Express, 端口 3001）
│   ├── services/     # 飞书服务
│   ├── routes/       # API 路由
│   └── index.js
├── memory/           # AI 记忆
├── obsidian/         # Obsidian vault
│   ├── 01-项目规划/
│   ├── 02-任务分配/
│   ├── 03-执行过程/
│   ├── 04-测试结果/
│   ├── 05-部署记录/
│   ├── 06-问题记录/
│   └── 07-每日总结/
├── scripts/          # 自动化脚本
├── CLAUDE.md         # AI 配置
└── install.bat       # 一键安装
```

## API

| 端点 | 方法 | 功能 |
|------|------|------|
| `/api/health` | GET | 健康检查 |
| `/api/generate-qr` | POST | 生成二维码 |
| `/api/monitor` | GET | 系统监控 |
| `/api/system-info` | GET | 系统信息 |
| `/api/feishu/send` | POST | 发飞书消息 |
| `/api/feishu/callback` | POST | 接收飞书事件 |
| `/api/obsidian/write` | POST | 写 Obsidian 笔记 |
| `/api/obsidian/list` | GET | 列笔记 |
| `/api/memory/read` | GET | 读记忆 |
| `/api/memory/write` | POST | 写记忆 |

## 配置飞书

1. 飞书群 → 设置 → 群机器人 → 添加 → 复制 Webhook URL
2. 编辑 `.env`，填 `FEISHU_WEBHOOK_URL=地址`
3. `bash scripts/restart.sh`

或: `bash scripts/feishu-setup.sh`

## Obsidian 笔记

1. 下载 [Obsidian](https://obsidian.md)
2. 打开 vault → 选择 `obsidian/` 目录
3. AI 的工作记录按分类排好了

## 常见问题

**后端启动失败？** 看 `backend/logs/backend.log`

**飞书收不到通知？** 检查 `.env` 里 `FEISHU_WEBHOOK_URL`
