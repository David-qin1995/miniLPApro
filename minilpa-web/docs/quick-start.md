# 快速开始

本指南将帮助您快速搭建 MiniLPA Web 开发环境。

## 环境准备

### 必需软件

- Node.js >= 16.0.0
- npm >= 8.0.0

### 验证环境

```bash
node -v  # 应输出 v16.0.0 或更高
npm -v   # 应输出 8.0.0 或更高
```

## 本地开发

### 1. 克隆项目

```bash
git clone <repository-url>
cd minilpa-web
```

### 2. 安装依赖

```bash
# 安装所有依赖（前端 + 后端）
npm run install:all

# 或者分别安装
npm install           # 后端依赖
cd client && npm install  # 前端依赖
```

### 3. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置（可选，默认配置即可用于开发）
vim .env
```

### 4. 启动开发服务器

```bash
# 同时启动前端和后端开发服务器
npm run dev
```

服务启动后：
- 前端: http://localhost:5173
- 后端: http://localhost:3000

### 5. 浏览器访问

打开浏览器访问 http://localhost:5173

## 项目结构

```
minilpa-web/
├── client/              # 前端项目
│   ├── src/
│   │   ├── api/        # API 接口
│   │   ├── assets/     # 静态资源
│   │   ├── components/ # 组件
│   │   ├── locales/    # 多语言
│   │   ├── router/     # 路由
│   │   ├── stores/     # 状态管理
│   │   ├── styles/     # 样式
│   │   ├── views/      # 页面
│   │   ├── App.vue     # 根组件
│   │   └── main.js     # 入口文件
│   └── package.json
├── server/              # 后端项目
│   ├── routes/         # 路由
│   ├── db.js           # 数据库
│   └── index.js        # 入口文件
├── docs/               # 文档
├── scripts/            # 脚本
├── package.json        # 后端依赖
└── README.md
```

## 开发指南

### 前端开发

前端使用 Vue 3 + Element Plus + Vite

```bash
cd client

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

### 后端开发

后端使用 Node.js + Express

```bash
# 启动开发服务器（支持热重载）
npm run server:dev

# 启动生产服务器
npm start
```

### API 文档

#### Profiles API

```
GET    /api/profiles           # 获取所有配置文件
GET    /api/profiles/:id       # 获取单个配置文件
POST   /api/profiles           # 创建配置文件
POST   /api/profiles/:id/enable    # 启用配置文件
POST   /api/profiles/:id/disable   # 禁用配置文件
PATCH  /api/profiles/:id       # 更新配置文件
DELETE /api/profiles/:id       # 删除配置文件
```

#### Notifications API

```
GET    /api/notifications      # 获取所有通知
GET    /api/notifications/:id  # 获取单个通知
POST   /api/notifications      # 创建通知
POST   /api/notifications/:id/process  # 处理通知
DELETE /api/notifications/:id  # 删除通知
POST   /api/notifications/batch/process  # 批量处理
POST   /api/notifications/batch/delete   # 批量删除
```

#### Chip API

```
GET    /api/chip               # 获取芯片信息
GET    /api/chip/certificate   # 获取证书信息
```

#### Settings API

```
GET    /api/settings           # 获取设置
PATCH  /api/settings           # 更新设置
PATCH  /api/settings/behavior  # 更新行为设置
POST   /api/settings/reset     # 重置设置
```

#### QR Code API

```
POST   /api/qrcode/parse       # 解析二维码图片
POST   /api/qrcode/parse-text  # 解析激活码文本
```

## 常用命令

```bash
# 安装所有依赖
npm run install:all

# 启动开发服务器（前端 + 后端）
npm run dev

# 仅启动后端开发服务器
npm run server:dev

# 仅启动前端开发服务器
cd client && npm run dev

# 构建前端
npm run build

# 启动生产服务器
npm start
```

## 调试技巧

### 前端调试

1. 使用浏览器开发者工具
2. Vue DevTools 扩展
3. Console 日志

### 后端调试

1. 查看控制台输出
2. 使用 Postman 测试 API
3. 查看日志文件 `logs/`

## 常见问题

### 端口被占用

修改端口号：

前端: `client/vite.config.js` 中的 `server.port`
后端: `.env` 文件中的 `PORT`

### 依赖安装失败

尝试清除缓存：

```bash
rm -rf node_modules client/node_modules
npm cache clean --force
npm run install:all
```

### 热重载不工作

检查文件监听限制：

```bash
# Linux/macOS
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 下一步

- 查看 [部署文档](./baota-deployment.md) 了解如何部署到生产环境
- 查看 [API 文档](./api.md) 了解详细的 API 使用方法
- 查看 [贡献指南](./contributing.md) 了解如何参与项目开发

## 技术支持

遇到问题？
- 查看 [FAQ](./faq.md)
- 提交 [Issue](https://github.com/your-repo/issues)
- 加入讨论群

---

祝开发愉快！ 🎉

