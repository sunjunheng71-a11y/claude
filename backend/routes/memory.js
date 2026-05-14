/**
 * 记忆系统 API
 * /api/memory/read  - 读取记忆
 * /api/memory/write - 写入记忆
 * /api/memory/list  - 列出记忆文件
 */

const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

const MEMORY_DIR = path.join(__dirname, '..', '..', 'memory');

// 获取记忆文件列表
router.get('/list', (req, res) => {
  try {
    if (!fs.existsSync(MEMORY_DIR)) {
      return res.json({ files: [] });
    }

    const files = fs.readdirSync(MEMORY_DIR)
      .filter(f => f.endsWith('.md'))
      .map(f => ({
        name: f,
        size: fs.statSync(path.join(MEMORY_DIR, f)).size,
        mtime: fs.statSync(path.join(MEMORY_DIR, f)).mtime
      }));

    res.json({ files });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 读取记忆文件
router.get('/read', (req, res) => {
  try {
    const { file } = req.query;
    if (!file) {
      return res.status(400).json({ error: 'file 参数不能为空' });
    }

    const filePath = path.join(MEMORY_DIR, file);
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: '文件不存在' });
    }

    const content = fs.readFileSync(filePath, 'utf-8');
    res.json({ file, content });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 写入/更新记忆文件
router.post('/write', (req, res) => {
  try {
    const { file, content, append } = req.body;
    if (!file || !content) {
      return res.status(400).json({ error: 'file 和 content 不能为空' });
    }

    // 安全检查：只允许写入 .md 文件
    if (!file.endsWith('.md')) {
      return res.status(400).json({ error: '只允许 .md 文件' });
    }

    // 防止路径穿越
    const safeName = path.basename(file);
    const filePath = path.join(MEMORY_DIR, safeName);

    if (!fs.existsSync(MEMORY_DIR)) {
      fs.mkdirSync(MEMORY_DIR, { recursive: true });
    }

    if (append && fs.existsSync(filePath)) {
      const existing = fs.readFileSync(filePath, 'utf-8');
      fs.writeFileSync(filePath, existing + '\n\n' + content, 'utf-8');
    } else {
      fs.writeFileSync(filePath, content, 'utf-8');
    }

    res.json({ success: true, file: safeName });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
