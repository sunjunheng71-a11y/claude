# 自动提交代码

当用户说"提交"、"commit"、"保存代码"时自动执行。

## 步骤
1. `git status` 查看变更
2. `git add` 所有变更文件（排除 .env, *.log）
3. `git commit -m "变更描述"`
4. `git push origin main`
5. 写入 Obsidian: `05-部署记录/` 提交记录
