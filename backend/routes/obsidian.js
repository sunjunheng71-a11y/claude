/**
 * Obsidian 笔记 API
 * /api/obsidian/write - 写入笔记
 * /api/obsidian/read - 读取笔记
 * /api/obsidian/list - 列出笔记
 */

const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

const OBSIDIAN_DIR = path.join(__dirname, '..', '..', 'obsidian');

// 分类映射
const FOLDERS = {
  '规划': '01-项目规划',
  '任务': '02-任务分配',
  '执行': '03-执行过程',
  '测试': '04-测试结果',
  '部署': '05-部署记录',
  '问题': '06-问题记录',
  '总结': '07-每日总结'
};

const FOLDER_NAMES = [
  '01-项目规划', '02-任务分配', '03-执行过程',
  '04-测试结果', '05-部署记录', '06-问题记录', '07-每日总结'
];

/**
 * 写入 Obsidian 笔记
 * POST /api/obsidian/write
 * Body: { folder, title, content, meta }
 */
router.post('/write', (req, res) => {
  try {
    let { folder, title, content, meta = {} } = req.body;

    if (!title || !content) {
      return res.status(400).json({ error: 'title 和 content 不能为空' });
    }

    // 解析 folder
    if (FOLDERS[folder]) {
      folder = FOLDERS[folder];
    } else if (!FOLDER_NAMES.includes(folder)) {
      folder = '01-项目规划'; // 默认放到规划目录
    }

    const folderPath = path.join(OBSIDIAN_DIR, folder);
    if (!fs.existsSync(folderPath)) {
      fs.mkdirSync(folderPath, { recursive: true });
    }

    // 生成文件名: YYYY-MM-DD-HHmm-标题.md
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = `${String(now.getHours()).padStart(2, '0')}${String(now.getMinutes()).padStart(2, '0')}`;
    const safeName = title.replace(/[\/\\:*?"<>|]/g, '-').slice(0, 50);
    const fileName = `${dateStr}-${timeStr}-${safeName}.md`;
    const filePath = path.join(folderPath, fileName);

    // 构建 frontmatter
    const frontmatter = [
      '---',
      `项目: ${meta.project || 'AI全自动开发平台'}`,
      `类型: ${meta.type || folder.split('-')[1] || '规划'}`,
      `日期: ${now.toISOString().slice(0, 16).replace('T', ' ')}`,
      `标签: [${(meta.tags || []).join(', ')}]`,
      `状态: ${meta.status || '已完成'}`,
      '---',
      '',
      `# ${title}`,
    ].join('\n');

    // 构建正文
    let bodyContent = '';
    if (meta.background) bodyContent += `\n## 背景\n${meta.background}\n`;
    if (meta.process) bodyContent += `\n## 过程\n${meta.process}\n`;
    if (meta.result) bodyContent += `\n## 结果\n${meta.result}\n`;
    if (meta.next) bodyContent += `\n## 下一步\n${meta.next}\n`;

    const fullContent = frontmatter + '\n' + content + bodyContent;

    fs.writeFileSync(filePath, fullContent, 'utf-8');

    res.json({
      success: true,
      path: path.relative(process.cwd(), filePath),
      folder,
      fileName
    });
  } catch (err) {
    console.error('Obsidian 写入失败:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 读取笔记
 * GET /api/obsidian/read?folder=01-项目规划&file=xxx.md
 */
router.get('/read', (req, res) => {
  try {
    const { folder, file } = req.query;
    if (!folder || !file) {
      return res.status(400).json({ error: 'folder 和 file 参数不能为空' });
    }

    const filePath = path.join(OBSIDIAN_DIR, folder, file);
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: '文件不存在' });
    }

    const content = fs.readFileSync(filePath, 'utf-8');
    res.json({ folder, file, content });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * 列出笔记
 * GET /api/obsidian/list?folder=01-项目规划（可选）
 */
router.get('/list', (req, res) => {
  try {
    const { folder } = req.query;

    const folders = folder ? [folder] : FOLDER_NAMES;
    const result = {};

    for (const f of folders) {
      const folderPath = path.join(OBSIDIAN_DIR, f);
      if (fs.existsSync(folderPath)) {
        const files = fs.readdirSync(folderPath)
          .filter(fn => fn.endsWith('.md') && fn !== '.gitkeep')
          .map(fn => ({
            name: fn,
            path: path.join(f, fn),
            mtime: fs.statSync(path.join(folderPath, fn)).mtime
          }))
          .sort((a, b) => b.mtime - a.mtime);

        if (files.length > 0) {
          result[f] = files;
        }
      }
    }

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * 获取笔记统计
 * GET /api/obsidian/stats
 */
router.get('/stats', (req, res) => {
  try {
    const stats = {};
    let total = 0;

    for (const folder of FOLDER_NAMES) {
      const folderPath = path.join(OBSIDIAN_DIR, folder);
      if (fs.existsSync(folderPath)) {
        const count = fs.readdirSync(folderPath)
          .filter(fn => fn.endsWith('.md') && fn !== '.gitkeep').length;
        stats[folder] = count;
        total += count;
      }
    }

    res.json({ folders: stats, total });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
