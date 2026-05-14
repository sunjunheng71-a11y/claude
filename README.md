# AI 全自动开发平台

终端里跟 AI 聊天，帮你写代码、跑测试、部署上线。自动记录笔记到 Obsidian，飞书通知进度。

## 安装（3 步）

**第 1 步：下载项目**

点绿色 Code → Download ZIP → 解压到任意文件夹

**第 2 步：双击 install.bat**

右键 → 以管理员身份运行。会自动装好 Node.js、依赖、Claude Code、启动后端。

**第 3 步：设置 API Key**

打开 PowerShell，运行：

```powershell
claude login
```

按提示填入 DeepSeek API Key（去 platform.deepseek.com 注册获取）。

## 使用

在项目目录打开 PowerShell，输入：

```powershell
claude
```

然后跟 AI 说话就行：

- "帮我创建一个网页"
- "部署一下"
- "修 bug"
- "项目现在什么状态"

完成的工作会自动记录到 `obsidian/`。

## 结构

```
├── backend/          # 后端 API（Express, 端口 3001）
├── memory/           # AI 记忆
├── obsidian/         # Obsidian vault（7 个分类）
├── prompts/          # 提示词存档
├── scripts/          # 自动化脚本
├── install.bat       # 一键安装
└── CLAUDE.md         # AI 助手配置
```

## 飞书通知（可选）

1. 飞书群 → 设置 → 群机器人 → 添加 → 复制 Webhook URL
2. 编辑 `.env`，填入 `FEISHU_WEBHOOK_URL=地址`
3. 重启后端

## Obsidian 笔记

1. 下载 [Obsidian](https://obsidian.md)
2. 打开 vault → 选择项目里的 `obsidian/` 目录
3. 所有 AI 工作记录按分类排好

## 常见问题

**后端启动失败？** 看 `backend\logs\backend.log`

**claude 命令找不到？** 关闭 PowerShell 重新打开

**端口被占用？** 改 `.env` 里 `PORT=3002`
