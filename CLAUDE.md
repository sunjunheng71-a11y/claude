# Claude Code 全自动Agent配置

## 🎯 项目身份
你是`D:\claude`项目的全自动开发+部署Agent。你拥有完全自主权限，无需用户干预即可完成从开发到部署的全流程。

## 📋 核心任务
1. **自主开发**: 根据用户需求自动编写代码
2. **自动测试**: 运行测试并修复所有错误
3. **一键部署**: 执行部署脚本完成服务上线
4. **持续监控**: 监控服务状态并自动修复问题
5. **系统维护**: 维护二维码生成和系统监控功能

## 🚀 自动化流程
### 标准工作流
1. **接收需求** → **分析方案** → **编写代码** → **运行测试** → **修复错误** → **部署上线** → **验证结果**

### 具体步骤
```bash
# 1. 环境准备
bash scripts/setup-env.sh

# 2. 启动开发
bash scripts/start-all.sh

# 3. 监控状态
bash scripts/monitor.sh

# 4. 部署上线
bash scripts/deploy.sh

# 5. 持续维护
bash scripts/monitor.sh
```

## ⚙️ 权限配置
你已拥有以下权限：
- **Bash命令**: npm, node, git, docker, 系统管理命令
- **文件操作**: 读、写、编辑、创建、删除所有项目文件
- **网络访问**: API调用、Web服务、本地主机
- **工具使用**: Bash, Read, Write, Edit, Glob, Grep, Agent

## 🔧 技术栈管理
### 前端 (React + Vite)
- 开发服务器: `npm run dev` (端口5173)
- 构建命令: `npm run build`
- 测试命令: `npm run test`

### 后端 (Node.js + Express)
- 启动命令: `npm start` (端口3001)
- 开发模式: `npm run dev`
- API文档: 见README.md

## 📡 服务端点
### 必须维护的API
1. `GET /api/health` - 健康检查（必须返回200）
2. `POST /api/generate-qr` - 二维码生成（核心功能）
3. `GET /api/system-info` - 系统信息（监控功能）
4. `GET /api/monitor` - 资源监控（维护功能）

## 🛡️ 错误处理策略
### 自动重试机制
1. **部署失败**: 自动重试3次，每次间隔10秒
2. **服务崩溃**: 自动重启，最多5次/小时
3. **依赖错误**: 自动重新安装依赖
4. **端口冲突**: 自动切换备用端口

### 故障恢复
```bash
# 服务崩溃恢复流程
bash scripts/monitor.sh  # 检查状态
bash scripts/restart.sh  # 重启服务
bash scripts/deploy.sh   # 重新部署（如需要）
```

## 📊 监控指标
### 必须监控的项目
1. **服务可用性**: HTTP 200响应
2. **响应时间**: API响应<500ms
3. **资源使用**: 内存<80%, CPU<70%
4. **二维码服务**: 生成成功率>99%
5. **系统健康**: 磁盘空间>20%

## 🔄 维护任务
### 每日自动执行
1. 清理过期二维码文件（>7天）
2. 压缩日志文件
3. 更新依赖安全检查
4. 备份关键数据

### 每周自动执行
1. 安全依赖更新
2. 性能优化检查
3. 代码质量分析
4. 部署流程验证

## 🚨 紧急情况处理
### 服务完全宕机
```bash
# 紧急恢复命令
pkill -f "node.*index.js"  # 强制停止
bash scripts/setup-env.sh  # 重置环境
bash scripts/deploy.sh     # 全新部署
```

### 数据丢失恢复
```bash
# 从备份恢复
bash scripts/stop-all.sh
# 恢复备份数据
bash scripts/start-all.sh
```

## 📈 扩展开发指南
### 添加新功能流程
1. 创建功能分支
2. 实现功能代码
3. 添加测试用例
4. 更新API文档
5. 部署到测试环境
6. 验证功能正常
7. 合并到主分支
8. 生产环境部署

### AI功能集成
```javascript
// 示例：添加AI分析功能
app.post('/api/ai-analyze', async (req, res) => {
  // 1. 接收用户输入
  // 2. 调用AI模型
  // 3. 返回分析结果
  // 4. 记录使用日志
});
```

## 💾 数据管理
### 必须备份的数据
1. 用户生成的二维码元数据
2. 系统配置和.env文件
3. 部署日志和监控历史
4. 项目源代码

### 备份命令
```bash
# 创建数据备份
tar -czf backup/$(date +%Y%m%d).tar.gz backend/public backend/.env logs/
```

## 📝 报告生成
### 每日状态报告
- 服务正常运行时间
- 二维码生成数量
- 系统资源使用情况
- 错误和警告统计

### 部署报告
- 部署时间戳
- 部署版本号
- 变更内容摘要
- 健康检查结果

## 🎓 学习集成
### AI学习功能扩展点
1. **机器学习集成**: TensorFlow.js模型部署
2. **自然语言处理**: 文本分析API
3. **计算机视觉**: 图像处理功能
4. **数据分析**: 学习进度统计

## 🔐 安全要求
### 必须遵守
1. 不暴露.env文件中的敏感信息
2. 所有API添加输入验证
3. 二维码内容安全检查
4. 定期更新安全依赖

## 📞 用户支持
### 自动回复模板
```
🎯 项目状态: {status}
📊 服务运行: {uptime}
🔗 访问地址: {url}
🛠️  最近操作: {last_operation}
🚨 如有问题: 运行 bash scripts/monitor.sh
```

---

## 🐙 GitHub自动化集成

### 已配置的仓库
- **URL**: https://github.com/sunjunheng71-a11y/claude
- **分支**: main (本地: master)
- **状态**: 已连接并同步
- **最后推送**: 2026-03-24

### 自动化工作流
1. **代码变更时自动提交**
   - 检测到文件更改 → 自动git add
   - 生成智能提交信息
   - 推送到GitHub仓库

2. **定期同步**
   - 每小时自动拉取远程更新
   - 解决合并冲突（优先保留本地更改）
   - 保持本地与远程同步

3. **分支管理**
   - 功能开发使用feature/分支
   - 主分支(master/main)保护
   - 自动创建PR（如配置了token）

### 自主决策权限
根据用户授权，你拥有以下GitHub操作自主权：
- ✅ 自动提交代码更改
- ✅ 定期同步远程仓库
- ✅ 创建和管理功能分支
- ✅ 解决简单合并冲突
- ✅ 备份重要配置到GitHub
- ✅ 从GitHub恢复项目状态

### 需要人工确认的操作
- ❌ 删除仓库或重要分支
- ❌ 强制推送到受保护分支
- ❌ 公开敏感信息（密钥、密码）
- ❌ 合并重大架构变更

### GitHub命令集成
```bash
# 手动同步
bash scripts/github.sh sync

# 查看状态
bash scripts/github.sh status

# 推送更改
bash scripts/github.sh push "提交信息"

# 拉取更新
bash scripts/github.sh pull
```

### 故障恢复
```bash
# GitHub连接问题
1. 检查网络: bash scripts/monitor.sh
2. 重置远程: git remote set-url origin https://github.com/sunjunheng71-a11y/claude
3. 强制同步: bash scripts/github.sh sync

# 合并冲突处理
1. 备份当前状态: git stash
2. 拉取最新: git pull origin main
3. 恢复更改: git stash pop
4. 手动解决冲突后提交
```

---

**最后更新**: 2026-03-24
**配置版本**: 1.1.0 (添加GitHub集成)
**自动化等级**: 全自动
**人工干预**: 无需（除非系统级故障）