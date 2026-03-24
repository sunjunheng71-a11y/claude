# AI学习平台 - 大学生AI学习与二维码系统

## 🎯 项目概述
一个专为大学生设计的AI学习平台，集成了二维码生成、系统监控和自动化部署功能。通过这个项目，你可以学习AI技术、Web开发和DevOps实践。

## 🚀 快速开始

### 环境要求
- Node.js 16+
- npm 8+
- Git

### 一键启动
```bash
# 克隆项目（如果从git仓库）
git clone <repository-url>
cd ai-learning-platform

# 设置环境
bash scripts/setup-env.sh

# 启动所有服务
bash scripts/start-all.sh
```

### 手动设置
```bash
# 安装后端依赖
cd backend
npm install

# 安装前端依赖
cd ../frontend
npm install

# 启动后端服务
cd ../backend
npm start

# 启动前端开发服务器（新终端）
cd ../frontend
npm run dev
```

## 📁 项目结构
```
D:\claude\
├── frontend/          # React前端应用
│   ├── src/
│   ├── public/
│   └── package.json
├── backend/           # Node.js后端API
│   ├── index.js      # 主服务器文件
│   ├── public/       # 二维码存储
│   ├── logs/         # 日志文件
│   └── package.json
├── scripts/          # 自动化脚本
│   ├── deploy.sh     # 部署脚本
│   ├── start-all.sh  # 启动所有服务
│   ├── stop-all.sh   # 停止所有服务
│   ├── restart.sh    # 重启服务
│   ├── monitor.sh    # 系统监控
│   └── setup-env.sh  # 环境设置
├── docs/             # 文档
├── logs/             # 系统日志
└── .claude/          # Claude Code配置
```

## 🔧 功能特性

### 1. 二维码生成系统
- **API端点**: `POST /api/generate-qr`
- **功能**: 将任意文本转换为二维码图片
- **参数**: `text` (必需), `size` (可选, 默认200)
- **返回**: QR图片URL和元数据

### 2. 系统监控
- **健康检查**: `GET /api/health` - 服务状态检查
- **系统信息**: `GET /api/system-info` - 服务器硬件信息
- **资源监控**: `GET /api/monitor` - 内存、CPU使用情况

### 3. 自动化部署
- 一键部署脚本 (`deploy.sh`)
- 自动依赖安装和构建
- 服务健康检查
- 部署日志记录

### 4. Claude Code集成
- 全自动开发Agent配置
- 预配置权限和hooks
- 自动化测试和部署

## 📡 API文档

### 后端API (端口: 3001)
| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/health` | GET | 服务健康检查 |
| `/api/generate-qr` | POST | 生成二维码 |
| `/api/system-info` | GET | 获取系统信息 |
| `/api/monitor` | GET | 获取监控数据 |

### 前端开发服务器 (端口: 5173)
- 开发模式: `http://localhost:5173`
- 热重载支持

## 🤖 Claude Code自动化配置

### 全自动Agent功能
本项目已配置Claude Code为全自动开发Agent，具备以下能力：

1. **自动开发**: 根据需求生成代码
2. **自动测试**: 运行测试并修复错误
3. **自动部署**: 执行部署脚本上线服务
4. **自动监控**: 持续监控服务状态

### 配置文件
- `.claude/config.json` - Claude Code配置
- 预配置权限: bash、文件操作、网络访问
- 自动化hooks: 部署前、部署后、监控

### 使用方法
```bash
# 让Claude Code接管项目开发
cd D:\claude
claude-code --auto

# 或通过VSCode扩展使用
```

## 🧠 AI学习资源

### 本项目涉及的技术栈
1. **前端**: React + Vite + 现代CSS
2. **后端**: Node.js + Express + RESTful API
3. **二维码**: qr-image库
4. **系统监控**: Node.js OS模块
5. **自动化**: Bash脚本 + 进程管理
6. **DevOps**: 部署脚本 + 监控工具

### 学习路径
1. 基础: Web开发、API设计
2. 进阶: 系统监控、自动化部署
3. 高级: AI集成、性能优化

## 🛠️ 维护指南

### 常用命令
```bash
# 启动所有服务
bash scripts/start-all.sh

# 停止所有服务
bash scripts/stop-all.sh

# 重启服务
bash scripts/restart.sh

# 查看监控
bash scripts/monitor.sh

# 部署到生产环境
bash scripts/deploy.sh
```

### 日志查看
```bash
# 后端日志
tail -f backend/logs/backend.log

# 前端日志
tail -f frontend/logs/frontend.log

# 部署日志
tail -f logs/deployments.log
```

### 故障排查
1. 检查服务是否运行: `bash scripts/monitor.sh`
2. 查看错误日志: `backend/logs/backend.log`
3. 重启服务: `bash scripts/restart.sh`
4. 重新部署: `bash scripts/deploy.sh`

## 📈 扩展计划

### 短期目标
- [ ] 添加用户认证系统
- [ ] 实现二维码历史记录
- [ ] 添加更多AI学习模块
- [ ] 优化前端界面

### 长期目标
- [ ] 集成机器学习模型
- [ ] 添加实时聊天功能
- [ ] 实现移动端应用
- [ ] 部署到云平台

## 📄 许可证
本项目仅供学习使用，遵循MIT许可证。

## 🤝 贡献指南
欢迎提交Issue和Pull Request！

## 📞 联系信息
- 项目维护者: 大学生AI学习者
- 项目位置: D:\claude
- 创建时间: 2026年3月24日

---
**💡 提示**: 这是一个学习项目，适合大学生逐步掌握AI和Web开发技术。从基础功能开始，逐步添加复杂特性。