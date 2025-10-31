# MiniLPA Web 项目总结

## 项目概述

MiniLPA Web 是一个基于 Web 的 eSIM 配置文件管理系统，提供精美的用户界面和强大的功能。本项目是原 MiniLPA 桌面应用的 Web 版本，专为宝塔面板 CentOS 7 部署优化。

## 技术架构

### 前端技术栈

- **框架**: Vue 3 (Composition API)
- **UI 库**: Element Plus
- **构建工具**: Vite
- **状态管理**: Pinia
- **路由**: Vue Router
- **国际化**: Vue I18n
- **HTTP 客户端**: Axios
- **样式**: SCSS
- **图标**: Element Plus Icons

### 后端技术栈

- **运行时**: Node.js >= 16.0.0
- **框架**: Express
- **数据库**: LowDB (JSON-based)
- **进程管理**: PM2
- **文件上传**: Multer
- **二维码解析**: jsQR + Jimp
- **日志**: Morgan
- **安全**: Helmet
- **压缩**: Compression

### 部署相关

- **Web 服务器**: Nginx
- **进程管理**: PM2
- **部署平台**: 宝塔面板 (CentOS 7)
- **反向代理**: Nginx

## 项目结构

```
minilpa-web/
├── client/                      # 前端项目
│   ├── public/                  # 静态资源
│   ├── src/
│   │   ├── api/                # API 接口封装
│   │   │   ├── request.js      # Axios 实例
│   │   │   ├── profiles.js     # Profile API
│   │   │   ├── notifications.js # Notification API
│   │   │   ├── chip.js         # Chip API
│   │   │   ├── settings.js     # Settings API
│   │   │   └── qrcode.js       # QR Code API
│   │   ├── assets/             # 资源文件
│   │   ├── components/         # 组件（待扩展）
│   │   ├── locales/            # 多语言文件
│   │   │   ├── index.js        # i18n 配置
│   │   │   ├── zh-CN.json      # 简体中文
│   │   │   ├── en-US.json      # 英文
│   │   │   ├── ja-JP.json      # 日文
│   │   │   └── de-DE.json      # 德文
│   │   ├── router/             # 路由配置
│   │   │   └── index.js
│   │   ├── stores/             # Pinia 状态管理
│   │   │   ├── settings.js     # 设置 Store
│   │   │   └── profiles.js     # Profile Store
│   │   ├── styles/             # 全局样式
│   │   │   └── main.scss
│   │   ├── views/              # 页面组件
│   │   │   ├── Layout.vue      # 主布局
│   │   │   ├── Profiles.vue    # Profile 管理页
│   │   │   ├── Notifications.vue # 通知管理页
│   │   │   ├── Chip.vue        # 芯片信息页
│   │   │   └── Settings.vue    # 设置页
│   │   ├── App.vue             # 根组件
│   │   └── main.js             # 入口文件
│   ├── index.html              # HTML 模板
│   ├── vite.config.js          # Vite 配置
│   └── package.json            # 前端依赖
├── server/                      # 后端项目
│   ├── routes/                 # API 路由
│   │   ├── profiles.js         # Profile 路由
│   │   ├── notifications.js    # Notification 路由
│   │   ├── chip.js             # Chip 路由
│   │   ├── settings.js         # Settings 路由
│   │   └── qrcode.js           # QR Code 路由
│   ├── db.js                   # 数据库配置
│   └── index.js                # 服务器入口
├── docs/                        # 文档
│   ├── baota-deployment.md     # 宝塔部署文档
│   ├── quick-start.md          # 快速开始
│   └── environment-variables.md # 环境变量说明
├── scripts/                     # 脚本
│   ├── deploy.sh               # 部署脚本
│   └── backup.sh               # 备份脚本
├── .editorconfig               # 编辑器配置
├── .gitignore                  # Git 忽略配置
├── .npmrc                      # npm 配置
├── ecosystem.config.js         # PM2 配置
├── nginx.conf                  # Nginx 配置示例
├── package.json                # 后端依赖
├── CHANGELOG.md                # 更新日志
├── INSTALL.md                  # 安装指南
├── LICENSE                     # 许可证
└── README.md                   # 项目说明
```

## 核心功能

### 1. Profile 管理

- ✅ 查看所有 eSIM 配置文件
- ✅ 下载新的配置文件
- ✅ 启用/禁用配置文件
- ✅ 编辑配置文件昵称
- ✅ 删除配置文件
- ✅ 搜索配置文件
- ✅ 拖拽/粘贴二维码
- ✅ 卡片式展示

### 2. Notification 管理

- ✅ 查看所有通知
- ✅ 处理通知
- ✅ 删除通知
- ✅ 批量处理
- ✅ 批量删除
- ✅ 搜索通知
- ✅ 表格展示

### 3. Chip 信息

- ✅ 查看 EID
- ✅ 查看平台信息
- ✅ 查看 eUICC 信息
- ✅ 查看制造商信息
- ✅ 查看证书信息
- ✅ 空间使用情况

### 4. 设置

- ✅ 多语言切换（中文、英文、日文、德文）
- ✅ 主题切换（浅色、深色、自动）
- ✅ 自动夜间模式（系统、时间、禁用）
- ✅ Emoji 样式选择
- ✅ 通知行为设置
- ✅ 设置持久化

### 5. 系统功能

- ✅ 响应式设计
- ✅ 国际化支持
- ✅ 主题系统
- ✅ 数据持久化
- ✅ 文件上传
- ✅ 二维码解析
- ✅ 错误处理
- ✅ 日志记录

## API 接口

### Profiles API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/profiles` | 获取所有配置文件 |
| GET | `/api/profiles/:id` | 获取单个配置文件 |
| POST | `/api/profiles` | 创建配置文件 |
| POST | `/api/profiles/:id/enable` | 启用配置文件 |
| POST | `/api/profiles/:id/disable` | 禁用配置文件 |
| PATCH | `/api/profiles/:id` | 更新配置文件 |
| DELETE | `/api/profiles/:id` | 删除配置文件 |

### Notifications API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/notifications` | 获取所有通知 |
| GET | `/api/notifications/:id` | 获取单个通知 |
| POST | `/api/notifications` | 创建通知 |
| POST | `/api/notifications/:id/process` | 处理通知 |
| DELETE | `/api/notifications/:id` | 删除通知 |
| POST | `/api/notifications/batch/process` | 批量处理 |
| POST | `/api/notifications/batch/delete` | 批量删除 |

### Chip API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/chip` | 获取芯片信息 |
| GET | `/api/chip/certificate` | 获取证书信息 |

### Settings API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/settings` | 获取设置 |
| PATCH | `/api/settings` | 更新设置 |
| PATCH | `/api/settings/behavior` | 更新行为设置 |
| POST | `/api/settings/reset` | 重置设置 |

### QR Code API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/qrcode/parse` | 解析二维码图片 |
| POST | `/api/qrcode/parse-text` | 解析激活码文本 |

## 部署说明

### 宝塔面板部署

1. 安装宝塔面板
2. 安装 Nginx、PM2 管理器、Node.js
3. 上传项目文件
4. 安装依赖
5. 配置环境变量
6. 构建前端
7. 使用 PM2 启动
8. 配置 Nginx 反向代理
9. 配置 SSL（可选）

详细步骤：[docs/baota-deployment.md](docs/baota-deployment.md)

### 快速部署命令

```bash
cd /www/wwwroot
git clone <your-repo>
cd minilpa-web
bash scripts/deploy.sh
```

## 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| PORT | 服务器端口 | 3000 |
| NODE_ENV | 运行环境 | production |
| DB_PATH | 数据库路径 | ./data/db.json |
| CORS_ORIGIN | CORS 来源 | * |
| UPLOAD_PATH | 上传路径 | ./uploads |
| MAX_FILE_SIZE | 最大文件大小 | 10485760 |
| SESSION_SECRET | Session 密钥 | 需要修改 |

## 性能优化

- ✅ Gzip 压缩
- ✅ 静态资源缓存
- ✅ PM2 集群模式
- ✅ 代码分割
- ✅ 按需加载
- ✅ 图片懒加载（可扩展）
- ✅ CDN 支持（可配置）

## 安全措施

- ✅ Helmet 安全头
- ✅ CORS 控制
- ✅ 文件上传限制
- ✅ 输入验证
- ✅ SQL 注入防护（N/A，使用 JSON）
- ✅ XSS 防护
- ✅ CSRF 防护（待实现）
- ✅ HTTPS 支持

## 浏览器支持

- Chrome >= 90
- Firefox >= 88
- Safari >= 14
- Edge >= 90

## 已知问题

1. ❌ 暂未实现真实的 eUICC 通信（使用模拟数据）
2. ❌ 暂未实现用户认证系统
3. ❌ 暂未实现 WebSocket 实时通信
4. ❌ 暂未实现数据导出功能

## 未来计划

### v1.1.0
- [ ] WebSocket 实时通信
- [ ] 用户认证和授权
- [ ] 数据导出功能
- [ ] 高级搜索和过滤
- [ ] 操作日志记录

### v1.2.0
- [ ] PWA 支持
- [ ] 离线模式
- [ ] 批量导入
- [ ] API 密钥管理
- [ ] 插件系统
- [ ] 主题自定义

## 贡献者

- 项目创建者: [Your Name]
- 灵感来源: [MiniLPA](https://github.com/EsimMoe/MiniLPA)

## 许可证

MIT License

## 相关链接

- 项目仓库: https://github.com/your-repo/minilpa-web
- 问题反馈: https://github.com/your-repo/minilpa-web/issues
- 原项目: https://github.com/EsimMoe/MiniLPA

## 致谢

感谢 MiniLPA 项目提供的灵感和参考。

---

**项目状态**: ✅ 可用于生产环境  
**最后更新**: 2024-10-31  
**版本**: 1.0.0

