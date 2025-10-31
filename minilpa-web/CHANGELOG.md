# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-10-31

### Added
- 初始版本发布
- Profile 配置文件管理功能
  - 下载配置文件
  - 启用/禁用配置文件
  - 编辑配置文件昵称
  - 删除配置文件
  - 搜索配置文件
- Notification 通知管理功能
  - 查看通知列表
  - 处理通知
  - 删除通知
  - 批量操作
- Chip 芯片信息查看
  - eUICC 信息
  - 制造商信息
  - 证书信息
- Settings 设置功能
  - 多语言切换 (中文、英文、日文、德文)
  - 主题切换 (浅色、深色、自动)
  - Emoji 样式选择
  - 行为设置
- 二维码解析功能
  - 支持拖拽二维码图片
  - 支持粘贴二维码图片
  - 支持文本激活码解析
- 响应式设计，支持各种设备
- 宝塔面板部署支持
- PM2 进程管理配置
- Nginx 反向代理配置

### Features
- 🎨 精美的 Material Design 风格界面
- 🌍 完整的国际化支持
- 🎭 主题系统（自动切换日夜主题）
- 📱 完全响应式设计
- ⚡ 快速的性能表现
- 🔒 安全的数据存储
- 📦 易于部署和维护

### Technical Stack
- **Frontend**: Vue 3 + Element Plus + Vite
- **Backend**: Node.js + Express
- **Database**: LowDB (JSON-based)
- **State Management**: Pinia
- **I18n**: Vue I18n
- **Icons**: Element Plus Icons

### Documentation
- 完整的部署文档
- 快速开始指南
- 环境变量配置说明
- API 文档

---

## Future Plans

### [1.1.0] - TBD
- [ ] WebSocket 实时通信
- [ ] 用户认证和授权
- [ ] 数据导出功能
- [ ] 高级搜索和过滤
- [ ] 操作日志记录
- [ ] 数据统计和图表

### [1.2.0] - TBD
- [ ] 移动端 PWA 支持
- [ ] 离线模式
- [ ] 批量导入功能
- [ ] API 密钥管理
- [ ] 插件系统
- [ ] 主题自定义

---

格式基于 [Keep a Changelog](https://keepachangelog.com/)
版本号遵循 [Semantic Versioning](https://semver.org/)

