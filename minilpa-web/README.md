# MiniLPA Web

<div align="center">
    <h3>精美的现代化 LPA UI (Web 版本)</h3>
</div>

## 简介

MiniLPA Web 是一个基于 Web 的 eSIM 配置文件管理系统，提供优雅的用户界面和强大的功能。

## 特性

- ✨ 精美的现代化界面
- 🌍 多语言支持 (中文、英文、日文、德文)
- 🎨 多主题支持，支持日夜间主题自动切换
- 📱 响应式设计，完美支持各种设备
- 🔍 搜索与快捷导航功能
- 📋 Profile 配置文件管理
- 🔔 通知管理
- 💳 芯片信息查看
- 📸 支持二维码扫描和粘贴
- ⚡ **支持真实 lpac 功能**（可选，也支持模拟模式）
- 🚀 快速部署到宝塔面板

## 技术栈

### 前端
- Vue 3
- Element Plus UI
- Vue Router
- Pinia (状态管理)
- Vue I18n (国际化)
- Vite

### 后端
- Node.js
- Express
- LowDB (轻量级数据库)
- **LPAC 集成**（真实 eSIM 管理）

## 安装

### 环境要求

- Node.js >= 16.0.0
- npm >= 8.0.0

### 本地开发

1. 克隆项目
```bash
git clone <repository-url>
cd minilpa-web
```

2. 安装依赖
```bash
npm run install:all
```

3. 配置环境变量
```bash
cp .env.example .env
# 编辑 .env 文件，修改相关配置
```

4. 启动开发服务器
```bash
npm run dev
```

前端访问: http://localhost:5173
后端访问: http://localhost:3000

### 生产部署

#### 方式一：宝塔面板部署（推荐）

**一键部署到 `/www/wwwroot/minilpa`：**

```bash
# SSH 登录服务器
cd /www/wwwroot
git clone <your-repo> minilpa
cd minilpa

# 一键部署
bash scripts/baota-deploy.sh
```

详见 [宝塔部署指南](./宝塔部署指南.md) 或 [快速参考](./快速部署到宝塔.txt)

#### 方式二：传统部署

1. 构建前端
```bash
npm run build
```

2. 启动服务器
```bash
npm start
```

## 项目结构

```
minilpa-web/
├── client/                 # 前端项目
│   ├── src/
│   │   ├── assets/        # 静态资源
│   │   ├── components/    # 组件
│   │   ├── views/         # 页面
│   │   ├── router/        # 路由
│   │   ├── stores/        # 状态管理
│   │   ├── locales/       # 多语言文件
│   │   ├── api/           # API 接口
│   │   └── utils/         # 工具函数
│   └── package.json
├── server/                 # 后端项目
│   ├── routes/            # 路由
│   ├── controllers/       # 控制器
│   ├── models/            # 数据模型
│   ├── middleware/        # 中间件
│   ├── utils/             # 工具函数
│   └── index.js           # 入口文件
├── docs/                   # 文档
├── package.json
└── README.md
```

## 功能说明

### Profile 管理
- 查看所有 eSIM 配置文件
- 下载新的配置文件
- 启用/禁用配置文件
- 删除配置文件
- 编辑配置文件昵称
- **支持真实 lpac 操作或模拟模式**

### 通知管理
- 查看所有通知
- 处理通知
- 删除通知
- 批量操作
- **真实通知处理（需要 lpac）**

### 芯片信息
- 查看 eUICC 信息
- 查看证书信息
- 查看制造商信息
- **读取真实芯片数据（需要 lpac + 硬件）**

### 设置
- 语言切换
- 主题切换
- 行为设置
- Emoji 样式选择

### LPAC 功能（可选）
- ✅ 自动检测 lpac 可用性
- ✅ 真实/模拟模式无缝切换
- ✅ 支持 PCSC 智能卡读卡器
- ✅ 完整的 eSIM 管理功能
- 📖 查看 [LPAC 配置说明](LPAC配置说明.md)

## 常见问题

### 如何在宝塔面板部署？
请查看 [宝塔部署文档](./docs/baota-deployment.md)

### 如何配置反向代理？
在宝塔面板中配置 Nginx 反向代理，将请求转发到 Node.js 应用。

### 数据存储在哪里？
数据默认存储在 `data/db.json` 文件中，可以通过环境变量修改路径。

## 许可证

MIT License

## 鸣谢

本项目灵感来源于 [MiniLPA](https://github.com/EsimMoe/MiniLPA)

