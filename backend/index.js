const express = require('express');
const cors = require('cors');
const qr = require('qr-image');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// 创建public目录用于存储生成的二维码
if (!fs.existsSync('public')) {
    fs.mkdirSync('public');
}

// 健康检查端点
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'AI Learning Platform API',
        version: '1.0.0'
    });
});

// 生成二维码端点
app.post('/api/generate-qr', (req, res) => {
    try {
        const { text, size = 200 } = req.body;
        
        if (!text) {
            return res.status(400).json({ error: 'Text content is required' });
        }

        // 生成唯一文件名
        const filename = `qr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}.png`;
        const filepath = path.join(__dirname, 'public', filename);
        
        // 生成二维码图片
        const qr_png = qr.image(text, { type: 'png', size: parseInt(size) });
        const writeStream = fs.createWriteStream(filepath);
        
        qr_png.pipe(writeStream);
        
        writeStream.on('finish', () => {
            res.json({
                success: true,
                qrUrl: `/public/${filename}`,
                text: text,
                size: size,
                timestamp: new Date().toISOString()
            });
        });
        
        writeStream.on('error', (err) => {
            console.error('QR generation error:', err);
            res.status(500).json({ error: 'Failed to generate QR code' });
        });
        
    } catch (error) {
        console.error('QR generation error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// 系统信息端点
app.get('/api/system-info', (req, res) => {
    const os = require('os');
    
    res.json({
        platform: os.platform(),
        arch: os.arch(),
        hostname: os.hostname(),
        uptime: os.uptime(),
        totalMemory: os.totalmem(),
        freeMemory: os.freemem(),
        loadAvg: os.loadavg(),
        cpus: os.cpus().length,
        nodeVersion: process.version,
        timestamp: new Date().toISOString()
    });
});

// 服务监控端点
app.get('/api/monitor', (req, res) => {
    const os = require('os');
    const used = process.memoryUsage();
    
    res.json({
        memory: {
            rss: `${Math.round(used.rss / 1024 / 1024)} MB`,
            heapTotal: `${Math.round(used.heapTotal / 1024 / 1024)} MB`,
            heapUsed: `${Math.round(used.heapUsed / 1024 / 1024)} MB`,
            external: `${Math.round(used.external / 1024 / 1024)} MB`
        },
        uptime: process.uptime(),
        cpuUsage: process.cpuUsage(),
        systemLoad: os.loadavg(),
        activeConnections: server ? server._connections : 0
    });
});

// 启动服务器
const server = app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🔗 QR Generator: POST http://localhost:${PORT}/api/generate-qr`);
    console.log(`🖥️  System Info: http://localhost:${PORT}/api/system-info`);
});

// 优雅关闭
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
    });
});

module.exports = app;
