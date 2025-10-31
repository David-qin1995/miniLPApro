# 安装指南

本指南提供 MiniLPA Web 的详细安装说明。

## 目录

- [系统要求](#系统要求)
- [快速安装](#快速安装)
- [详细安装步骤](#详细安装步骤)
- [宝塔面板安装](#宝塔面板安装)
- [Docker 安装](#docker-安装)
- [验证安装](#验证安装)
- [故障排查](#故障排查)

## 系统要求

### 硬件要求

- CPU: 1核或以上
- 内存: 512MB 或以上
- 磁盘: 1GB 可用空间

### 软件要求

- **操作系统**: Linux (推荐 CentOS 7/8, Ubuntu 18.04+), macOS, Windows
- **Node.js**: >= 16.0.0
- **npm**: >= 8.0.0
- **Nginx**: 最新稳定版 (生产环境)

## 快速安装

### 一键安装脚本

```bash
# 下载安装脚本
curl -o install.sh https://raw.githubusercontent.com/your-repo/minilpa-web/main/scripts/install.sh

# 运行安装脚本
bash install.sh
```

### 手动快速安装

```bash
# 1. 克隆项目
git clone https://github.com/your-repo/minilpa-web.git
cd minilpa-web

# 2. 安装依赖
npm run install:all

# 3. 配置环境
cp .env.sample .env
vim .env  # 编辑配置

# 4. 构建前端
npm run build

# 5. 启动服务
npm start
```

## 详细安装步骤

### 1. 安装 Node.js

#### CentOS/RHEL

```bash
# 安装 Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# 验证安装
node -v
npm -v
```

#### Ubuntu/Debian

```bash
# 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node -v
npm -v
```

#### macOS

```bash
# 使用 Homebrew
brew install node@18

# 验证安装
node -v
npm -v
```

#### Windows

下载并安装 Node.js: https://nodejs.org/

### 2. 克隆项目

```bash
# 使用 HTTPS
git clone https://github.com/your-repo/minilpa-web.git

# 或使用 SSH
git clone git@github.com:your-repo/minilpa-web.git

# 进入项目目录
cd minilpa-web
```

### 3. 安装依赖

```bash
# 安装所有依赖（前端 + 后端）
npm run install:all

# 或者分别安装
npm install              # 后端依赖
cd client && npm install # 前端依赖
cd ..
```

### 4. 配置环境变量

```bash
# 复制示例配置
cp .env.sample .env

# 编辑配置文件
vim .env
```

必须修改的配置项：

```env
# 生产环境必须修改
NODE_ENV=production
SESSION_SECRET=your-random-secret-key

# 如果使用域名，修改 CORS
CORS_ORIGIN=https://yourdomain.com
```

### 5. 构建前端

```bash
npm run build
```

### 6. 启动应用

#### 开发环境

```bash
npm run dev
```

#### 生产环境

```bash
# 使用 PM2 (推荐)
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# 或直接启动
npm start
```

### 7. 配置 Nginx (生产环境)

```bash
# 复制 Nginx 配置
sudo cp nginx.conf /etc/nginx/conf.d/minilpa-web.conf

# 编辑配置文件
sudo vim /etc/nginx/conf.d/minilpa-web.conf
# 修改 server_name 为你的域名

# 测试配置
sudo nginx -t

# 重载 Nginx
sudo nginx -s reload
```

## 宝塔面板安装

详细步骤请参考: [宝塔部署文档](docs/baota-deployment.md)

### 简要步骤

1. 安装宝塔面板
2. 安装 Nginx 和 PM2 管理器
3. 上传项目文件或使用 Git
4. 安装依赖
5. 配置环境变量
6. 构建前端
7. 使用 PM2 启动应用
8. 配置 Nginx 反向代理
9. 配置 SSL (可选)

### 宝塔一键部署命令

```bash
cd /www/wwwroot
git clone https://github.com/your-repo/minilpa-web.git
cd minilpa-web
bash scripts/deploy.sh
```

## Docker 安装

### 使用 Docker Compose (推荐)

```bash
# 克隆项目
git clone https://github.com/your-repo/minilpa-web.git
cd minilpa-web

# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 使用 Docker

```bash
# 构建镜像
docker build -t minilpa-web .

# 运行容器
docker run -d \
  --name minilpa-web \
  -p 3000:3000 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/uploads:/app/uploads \
  -e NODE_ENV=production \
  minilpa-web

# 查看日志
docker logs -f minilpa-web
```

## 验证安装

### 1. 检查服务状态

```bash
# PM2
pm2 status

# 直接运行
curl http://localhost:3000/api/health
```

### 2. 访问应用

打开浏览器访问:
- 本地: http://localhost:3000
- 域名: http://yourdomain.com

### 3. 检查功能

- [ ] 页面正常加载
- [ ] 导航菜单工作正常
- [ ] 可以切换语言
- [ ] 可以切换主题
- [ ] API 正常响应

## 故障排查

### 依赖安装失败

```bash
# 清除缓存
rm -rf node_modules client/node_modules
npm cache clean --force

# 重新安装
npm run install:all
```

### 端口被占用

```bash
# 查看端口占用
lsof -i :3000
netstat -tlnp | grep 3000

# 修改端口
vim .env  # 修改 PORT 值
```

### PM2 启动失败

```bash
# 查看日志
pm2 logs minilpa-web

# 重启
pm2 restart minilpa-web

# 删除并重新启动
pm2 delete minilpa-web
pm2 start ecosystem.config.js
```

### Nginx 配置错误

```bash
# 测试配置
nginx -t

# 查看错误日志
tail -f /var/log/nginx/error.log

# 重载配置
nginx -s reload
```

### 数据库文件权限问题

```bash
# 创建数据目录
mkdir -p data uploads

# 设置权限
chmod -R 755 data uploads
chown -R www:www data uploads  # 宝塔环境
```

### 前端页面空白

```bash
# 检查构建产物
ls -la client/dist

# 重新构建
npm run build

# 检查 Nginx 配置
nginx -t
```

### API 请求失败

1. 检查后端是否正常运行
2. 检查 CORS 配置
3. 检查 Nginx 反向代理配置
4. 查看浏览器控制台错误

## 升级安装

### 从旧版本升级

```bash
# 备份数据
bash scripts/backup.sh

# 拉取最新代码
git pull origin main

# 安装依赖
npm run install:all

# 构建前端
npm run build

# 重启服务
pm2 restart minilpa-web
```

## 卸载

### 完全卸载

```bash
# 停止服务
pm2 stop minilpa-web
pm2 delete minilpa-web

# 删除项目文件
rm -rf /path/to/minilpa-web

# 删除 Nginx 配置
sudo rm /etc/nginx/conf.d/minilpa-web.conf
sudo nginx -s reload

# 删除 PM2 配置
pm2 unstartup
```

## 下一步

安装完成后，您可以：

- 阅读 [快速开始](docs/quick-start.md) 了解基本使用
- 阅读 [API 文档](docs/api.md) 了解 API 使用
- 查看 [常见问题](docs/faq.md) 解决常见问题

## 获取帮助

- 查看文档: [docs/](docs/)
- 提交 Issue: https://github.com/your-repo/issues
- 加入讨论: [Discord/Telegram/QQ群]

---

安装遇到问题？欢迎提交 Issue 或联系我们！

