/**
 * 飞书 Bot 路由
 * /api/feishu/send  - 发送消息
 * /api/feishu/callback - 接收飞书事件
 */

const express = require('express');
const router = express.Router();
const feishu = require('../services/feishu');
const { exec } = require('child_process');

// 发送飞书消息
router.post('/send', async (req, res) => {
  try {
    const { message, title } = req.body;
    if (!message) {
      return res.status(400).json({ error: '消息内容不能为空' });
    }

    const result = await feishu.sendViaWebhook(message, title);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 接收飞书事件回调
router.post('/callback', async (req, res) => {
  try {
    const body = req.body;

    // URL 验证（飞书首次配置时）
    if (body.type === 'url_verification') {
      return res.json({ challenge: body.challenge });
    }

    // 处理消息事件
    if (body.header?.event_type === 'im.message.receive_v1') {
      const event = body.event;
      const msgContent = JSON.parse(event.message?.content || '{}');
      const text = msgContent.text || '';
      const sender = event.sender?.sender_id?.open_id || 'unknown';

      // 检查是否为命令
      if (text.startsWith('/')) {
        const command = text.split(' ')[0].toLowerCase();
        let response = '';

        switch (command) {
          case '/status':
            response = '服务正在运行中。详情请查看 http://localhost:3001/api/health';
            break;
          case '/deploy':
            exec('bash scripts/deploy.sh', { cwd: process.env.PROJECT_ROOT || process.cwd() });
            response = '部署已触发，完成后会通知你。';
            break;
          case '/monitor':
            response = '监控数据: http://localhost:3001/api/monitor';
            break;
          case '/todo':
            response = '任务列表: 查看 Obsidian vault 的 02-任务分配/ 目录';
            break;
          case '/help':
            response = '支持的命令:\n/status - 查看状态\n/deploy - 触发部署\n/monitor - 系统监控\n/todo - 任务列表\n/help - 帮助';
            break;
          default:
            response = `未知命令: ${command}。输入 /help 查看支持的命令。`;
        }

        await feishu.sendViaWebhook(response, '命令响应');
      }
    }

    res.json({ code: 0 });
  } catch (err) {
    console.error('飞书回调处理失败:', err);
    res.json({ code: 0, msg: 'ok' }); // 飞书要求返回 200
  }
});

// 发送部署通知
router.post('/notify/deploy', async (req, res) => {
  try {
    const result = await feishu.notifyDeploy(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 发送告警
router.post('/notify/alert', async (req, res) => {
  try {
    const { level, title, content } = req.body;
    const result = await feishu.notifyAlert(level || 'info', title || '告警', content);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 发送每日报告
router.post('/notify/daily', async (req, res) => {
  try {
    const result = await feishu.notifyDailyReport(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
