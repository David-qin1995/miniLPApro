const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// 静态文件
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
app.use(express.static(path.join(__dirname, '../client/dist')));

// API 路由
app.use('/api/profiles', require('./routes/profiles'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/chip', require('./routes/chip'));
app.use('/api/settings', require('./routes/settings'));
app.use('/api/qrcode', require('./routes/qrcode'));
app.use('/api/lpac', require('./routes/lpac'));

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// SPA 回退
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../client/dist/index.html'));
});

// 错误处理
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500
    }
  });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║          MiniLPA Web Server is running!              ║
║                                                       ║
║          Port: ${PORT}                                    ║
║          Environment: ${process.env.NODE_ENV || 'development'}                     ║
║                                                       ║
║          Access at: http://localhost:${PORT}            ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
  `);
});

module.exports = app;

