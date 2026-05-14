/**
 * 飞书 Bot 服务
 * 负责发送消息到飞书、处理飞书事件回调
 */

const https = require('https');
const http = require('http');
const crypto = require('crypto');

class FeishuService {
  constructor() {
    this.appId = process.env.FEISHU_APP_ID || '';
    this.appSecret = process.env.FEISHU_APP_SECRET || '';
    this.webhookUrl = process.env.FEISHU_WEBHOOK_URL || '';
    this.verifyToken = process.env.FEISHU_VERIFY_TOKEN || '';
    this._tenantToken = null;
    this._tokenExpireAt = 0;
  }

  /**
   * 获取 tenant_access_token（用于主动调用飞书 API）
   */
  async getTenantToken() {
    if (this._tenantToken && Date.now() < this._tokenExpireAt) {
      return this._tenantToken;
    }

    return new Promise((resolve, reject) => {
      const body = JSON.stringify({
        app_id: this.appId,
        app_secret: this.appSecret
      });

      const req = https.request({
        hostname: 'open.feishu.cn',
        path: '/open-apis/auth/v3/tenant_access_token/internal',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const result = JSON.parse(data);
            if (result.code === 0) {
              this._tenantToken = result.tenant_access_token;
              this._tokenExpireAt = Date.now() + (result.expire - 60) * 1000;
              resolve(this._tenantToken);
            } else {
              reject(new Error(`飞书 Token 获取失败: ${result.msg}`));
            }
          } catch (e) {
            reject(e);
          }
        });
      });

      req.on('error', reject);
      req.write(body);
      req.end();
    });
  }

  /**
   * 通过 webhook 发送消息（最简单，只需 webhook URL）
   */
  async sendViaWebhook(message, title) {
    if (!this.webhookUrl) {
      console.warn('飞书 Webhook URL 未配置');
      return { success: false, error: 'Webhook URL 未配置' };
    }

    const url = new URL(this.webhookUrl);

    const body = JSON.stringify({
      msg_type: 'interactive',
      card: {
        header: {
          title: { tag: 'plain_text', content: title || 'AI 助手通知' },
          template: 'blue'
        },
        elements: [
          {
            tag: 'markdown',
            content: message
          },
          {
            tag: 'note',
            elements: [
              { tag: 'plain_text', content: `${new Date().toLocaleString('zh-CN')} · 自动发送` }
            ]
          }
        ]
      }
    });

    return new Promise((resolve, reject) => {
      const protocol = url.protocol === 'https:' ? https : http;
      const req = protocol.request({
        hostname: url.hostname,
        path: url.pathname + url.search,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            resolve({ success: true, status: res.statusCode, data: JSON.parse(data) });
          } catch (e) {
            resolve({ success: true, status: res.statusCode });
          }
        });
      });

      req.on('error', reject);
      req.write(body);
      req.end();
    });
  }

  /**
   * 发送简单文本消息
   */
  async sendText(content) {
    if (this.webhookUrl) {
      return this.sendViaWebhook(content, '系统通知');
    }

    // 如果有 appId，用飞书 API 发送
    if (this.appId && this.appSecret) {
      try {
        const token = await this.getTenantToken();
        // 此处需要 chat_id，简化处理
        console.log('通过 Bot API 发送需要 chat_id，请使用 webhook 方式');
        return { success: false, error: '需要 chat_id' };
      } catch (e) {
        return { success: false, error: e.message };
      }
    }

    return { success: false, error: '未配置飞书' };
  }

  /**
   * 发送部署通知
   */
  async notifyDeploy(deployInfo) {
    const msg = [
      `**部署完成**`,
      ``,
      `- 版本: ${deployInfo.version || 'latest'}`,
      `- 时间: ${deployInfo.time || new Date().toLocaleString('zh-CN')}`,
      `- 健康检查: ${deployInfo.health || 'OK'}`,
      `- 变更: ${deployInfo.changes || '无'}`,
    ].join('\n');

    return this.sendViaWebhook(msg, '部署通知');
  }

  /**
   * 发送告警
   */
  async notifyAlert(level, title, content) {
    const colors = { error: 'red', warning: 'yellow', info: 'blue' };
    const msg = [
      `**${level.toUpperCase()}**: ${content}`,
      `触发时间: ${new Date().toLocaleString('zh-CN')}`,
    ].join('\n');

    return this.sendViaWebhook(msg, `[${level.toUpperCase()}] ${title}`);
  }

  /**
   * 发送每日报告
   */
  async notifyDailyReport(report) {
    const msg = [
      `**今日工作总结**`,
      ``,
      `- 完成任务: ${report.completed || 0} 个`,
      `- 进行中: ${report.inProgress || 0} 个`,
      `- 部署次数: ${report.deploys || 0} 次`,
      `- Bug 修复: ${report.bugFixes || 0} 个`,
      `- 服务状态: ${report.health || '未知'}`,
    ].join('\n');

    return this.sendViaWebhook(msg, '每日报告');
  }

  /**
   * 验证飞书回调请求签名
   */
  verifySignature(timestamp, nonce, body) {
    const raw = timestamp + nonce + this.verifyToken + body;
    const signature = crypto.createHmac('sha256', this.verifyToken).update(raw).digest('base64');
    return signature;
  }
}

module.exports = new FeishuService();
