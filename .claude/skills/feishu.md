# 飞书通知

当需要通知用户时自动执行。

## 发送方式
```bash
curl -X POST "http://localhost:3001/api/feishu/send" \
  -H "Content-Type: application/json" \
  -d '{"message": "内容", "title": "标题"}'
```

## 触发时机
- 部署完成 → notify/deploy
- 服务异常 → notify/alert
- 每日定时 → notify/daily
