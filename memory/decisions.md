# 决策记录

## 架构决策

### 2026-05-14: 删除前端界面
- **决策**: 删除 React 前端，学生只用 PowerShell + Claude Code 聊天
- **原因**: 用户是编程新手，不需要浏览器界面。Claude Code 在终端里对话即可
- **影响**: frontend/ 目录不再使用

### 2026-05-14: 选择 Obsidian 作为笔记系统
- **决策**: 在项目内建 Obsidian vault，Claude 自动写笔记
- **原因**: Obsidian 使用 Markdown，零学习成本，本地存储，学生可用 Obsidian 打开浏览项目全貌
- **替代方案**: Notion API（需网络）、纯文件日志（无结构）

### 2026-05-14: 飞书 Bot 集成
- **决策**: 使用飞书自定义 Bot + Webhook
- **原因**: 中国大学生普遍用飞书，Bot 可双向交互
- **实现**: backend/services/feishu.js + routes/feishu.js

### 2026-03-24: 选择 ccswith 管理 Claude 登录
- **决策**: 使用 ccswith 作为 Claude Code 的登录/配置管理工具
- **原因**: 简化 Windows 上的 Claude Code 认证流程
- **路径**: %USERPROFILE%\.cc-switch
