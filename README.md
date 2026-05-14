# AI 全自动开发平台

这是一个面向零基础用户的 AI 开发工作台。它会安装 Claude Code、启动本地后端服务，并把项目记忆、执行记录和 Obsidian 笔记目录放在同一个项目里，方便持续迭代。

## 最简单安装方式：Download ZIP

适合不会用命令行的用户。

1. 打开本仓库页面。
2. 点击绿色 `Code` 按钮。
3. 点击 `Download ZIP`。
4. 解压 ZIP。
5. 右键 `install.bat`，选择“以管理员身份运行”。

脚本会自动完成：

- 检查并安装 Node.js LTS
- 安装后端依赖
- 安装 `@anthropic-ai/claude-code`
- 创建 `.env`
- 启动本地后端服务

安装结束后，重新打开 PowerShell：

```powershell
claude login
```

按提示填写你的 API Key。登录完成后，在项目目录运行：

```powershell
claude
```

## 命令行自动安装方式

适合熟悉 PowerShell 的用户。这个方式会自动下载或更新项目代码。

以管理员身份打开 PowerShell，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

默认安装目录是：

```text
%USERPROFILE%\ai-platform
```

也可以指定安装目录：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallDir "D:\ai-platform"
```

## 项目结构

```text
backend/      后端 API，默认端口 3001
frontend/     前端项目
memory/       AI 项目记忆
obsidian/     Obsidian vault
prompts/      提示词存档
scripts/      自动化脚本
install.bat   ZIP 用户的一键安装脚本
install.ps1   命令行自动下载/更新安装脚本
CLAUDE.md     Claude Code 项目指令
```

## 飞书通知（可选）

1. 在飞书群里添加群机器人，复制 Webhook URL。
2. 编辑项目根目录的 `.env`。
3. 填写：

```env
FEISHU_WEBHOOK_URL=你的飞书机器人 Webhook
```

4. 重启后端服务。

## Obsidian 笔记

1. 下载并安装 [Obsidian](https://obsidian.md)。
2. 打开 vault 时选择项目里的 `obsidian/` 目录。
3. AI 工作记录和项目资料会按目录保存。

## 常见问题

### `claude` 命令找不到

关闭当前 PowerShell，重新打开后再运行：

```powershell
claude
```

### 后端没有启动

查看日志：

```text
logs\backend.log
logs\backend-error.log
```

### 端口 3001 被占用

编辑 `.env`，把端口改成其他空闲端口：

```env
PORT=3002
```

然后重新启动后端。

### 我已经安装过 Claude Code

脚本会重新执行全局安装命令，通常会更新到可用版本。如果你不想改动现有 Claude Code 环境，请不要运行安装脚本，手动查看脚本内容后选择需要的步骤执行。
