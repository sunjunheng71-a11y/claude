# 系统监控

当用户说"监控"、"状态"、"monitor"、"status"时自动执行。

## 步骤
1. `bash scripts/monitor.sh`
2. 汇总服务状态、CPU/内存、日志
3. 如有异常，飞书告警: `POST /api/feishu/notify/alert`
4. 写入 Obsidian: `07-每日总结/`
