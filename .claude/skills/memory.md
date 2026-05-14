# 管理项目记忆

当用户说"记住 xxx"、"忘记 xxx"、"项目现在什么状态"时执行。

## 读记忆
- 每次对话开始自动读取 memory/ 下全部文件
- 后端: `GET /api/memory/read?file=xxx`

## 写记忆
- 自动写入对应文件
- 后端: `POST /api/memory/write`

## 记忆分类
- project.md → 项目概述、功能、技术栈
- decisions.md → 技术决策
- progress.md → 进度、最近完成
- issues.md → 已知问题
