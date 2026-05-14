# 项目记忆

## 项目概述
- **名称**: AI全自动开发平台
- **目标用户**: 编程零基础大学生
- **核心能力**: 通过 Claude Code 实现自动开发、测试、部署
- **通知方式**: 飞书 Bot
- **笔记系统**: 自动写入 Obsidian vault

## 当前功能
- 二维码生成（POST /api/generate-qr）
- 系统监控（/api/monitor, /api/system-info）
- 健康检查（/api/health）
- 飞书 Bot 通知
- Obsidian 笔记自动记录
- 全自动部署（scripts/deploy.sh）
- GitHub 同步

## 技术栈
- 后端: Node.js + Express（端口 3001）
- 运行时: Node.js 16+
- 部署: Bash 脚本 + PM2
- 数据库: SQLite（通过 ccswith）
- AI: Claude Code（全自动 Agent）
- 通知: 飞书 Bot API
- 笔记: Obsidian（Markdown + Frontmatter）
- 版本控制: Git + GitHub

## 项目路径
- 开发目录: 项目根目录
- 后端代码: backend/
- 记忆文件: memory/
- Obsidian Vault: obsidian/
- 脚本: scripts/
