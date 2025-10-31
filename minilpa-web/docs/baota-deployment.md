# 宝塔面板部署文档

本文档详细说明如何在宝塔面板 (CentOS 7) 上部署 MiniLPA Web 项目。

## 环境要求

- CentOS 7 服务器
- 宝塔面板 7.x 或更高版本
- Node.js >= 16.0.0
- Nginx

## 部署步骤

### 1. 安装宝塔面板

如果尚未安装宝塔面板，请执行以下命令：

```bash
yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh
```

安装完成后，记录面板地址、用户名和密码。

### 2. 安装必要的软件

在宝塔面板中安装以下软件：

1. **Nginx** (推荐最新版本)
2. **PM2 管理器** (用于管理 Node.js 应用)
3. **Node.js 版本管理器**

安装步骤：
- 登录宝塔面板
- 进入"软件商店"
- 搜索并安装 Nginx、PM2 管理器
- 安装 Node.js (推荐 v18 或 v20)

### 3. 上传项目文件

#### 方法一：使用 Git (推荐)

```bash
# SSH 登录服务器
cd /www/wwwroot

# 克隆项目
git clone <your-repository-url> minilpa-web

cd minilpa-web
```

#### 方法二：手动上传

1. 在宝塔面板中进入"文件"管理
2. 创建目录 `/www/wwwroot/minilpa-web`
3. 将项目文件上传到该目录

### 4. 安装依赖

```bash
cd /www/wwwroot/minilpa-web

# 安装后端依赖
npm install

# 安装前端依赖
cd client
npm install
cd ..
```

### 5. 配置环境变量

```bash
# 创建 .env 文件
cp .env.example .env

# 编辑配置
vi .env
```

修改以下配置：

```env
PORT=3000
NODE_ENV=production
DB_PATH=./data/db.json
CORS_ORIGIN=https://yourdomain.com
SESSION_SECRET=your-random-secret-key
```

### 6. 构建前端

```bash
npm run build
```

### 7. 使用 PM2 启动应用

#### 方法一：使用宝塔 PM2 管理器 (推荐)

1. 登录宝塔面板
2. 进入"软件商店" → "PM2 管理器"
3. 点击"添加项目"
4. 填写以下信息：
   - 项目名称: minilpa-web
   - 启动文件: /www/wwwroot/minilpa-web/server/index.js
   - 运行目录: /www/wwwroot/minilpa-web
   - 端口: 3000
5. 点击"提交"

#### 方法二：使用命令行

```bash
# 安装 PM2
npm install -g pm2

# 启动应用
cd /www/wwwroot/minilpa-web
pm2 start server/index.js --name minilpa-web

# 设置开机自启
pm2 startup
pm2 save
```

### 8. 配置 Nginx 反向代理

#### 方法一：使用宝塔面板配置 (推荐)

1. 登录宝塔面板
2. 进入"网站"
3. 点击"添加站点"
   - 域名: yourdomain.com
   - 根目录: /www/wwwroot/minilpa-web/client/dist
   - PHP版本: 纯静态
4. 点击站点名称 → "设置" → "反向代理"
5. 添加反向代理：
   - 代理名称: minilpa-api
   - 目标URL: http://127.0.0.1:3000
   - 发送域名: $host
   - 内容替换: 留空
6. 点击"保存"

#### 方法二：手动配置 Nginx

编辑 Nginx 配置文件：

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # 前端静态文件
    location / {
        root /www/wwwroot/minilpa-web/client/dist;
        try_files $uri $uri/ /index.html;
        index index.html;
    }

    # API 反向代理
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 上传文件访问
    location /uploads {
        proxy_pass http://127.0.0.1:3000;
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
```

重载 Nginx：

```bash
nginx -t
nginx -s reload
```

### 9. 配置 SSL 证书 (可选但推荐)

#### 使用宝塔面板配置 SSL

1. 进入站点设置 → "SSL"
2. 选择 "Let's Encrypt" 或上传自己的证书
3. 点击"申请"或"部署"
4. 开启"强制HTTPS"

### 10. 设置防火墙

确保以下端口已开放：

- 80 (HTTP)
- 443 (HTTPS)
- 3000 (Node.js 应用，仅内网访问)

在宝塔面板中：
1. 进入"安全"
2. 添加端口规则
3. 开放 80 和 443 端口

### 11. 验证部署

访问 `http://yourdomain.com` 或 `https://yourdomain.com`

检查：
- 前端页面是否正常加载
- API 是否正常响应
- 功能是否正常工作

### 12. 监控和维护

#### 查看应用状态

```bash
pm2 status
pm2 logs minilpa-web
```

#### 重启应用

```bash
pm2 restart minilpa-web
```

#### 更新应用

```bash
cd /www/wwwroot/minilpa-web

# 拉取最新代码
git pull

# 安装依赖
npm install
cd client && npm install && cd ..

# 重新构建前端
npm run build

# 重启应用
pm2 restart minilpa-web
```

## 常见问题

### 1. 端口被占用

如果 3000 端口被占用，可以修改 `.env` 文件中的 `PORT` 配置，然后更新 Nginx 反向代理配置。

### 2. 权限问题

确保项目目录有正确的权限：

```bash
chown -R www:www /www/wwwroot/minilpa-web
chmod -R 755 /www/wwwroot/minilpa-web
```

### 3. Node.js 版本问题

确保使用 Node.js 16 或更高版本：

```bash
node -v
npm -v
```

如果版本过低，请升级：

```bash
# 使用 nvm
nvm install 18
nvm use 18

# 或使用宝塔面板的 Node.js 版本管理器
```

### 4. 数据库文件权限

确保数据目录可写：

```bash
mkdir -p /www/wwwroot/minilpa-web/data
chown -R www:www /www/wwwroot/minilpa-web/data
chmod -R 755 /www/wwwroot/minilpa-web/data
```

### 5. 上传文件失败

确保上传目录存在且可写：

```bash
mkdir -p /www/wwwroot/minilpa-web/uploads
chown -R www:www /www/wwwroot/minilpa-web/uploads
chmod -R 755 /www/wwwroot/minilpa-web/uploads
```

### 6. PM2 无法启动

检查日志：

```bash
pm2 logs minilpa-web
```

常见原因：
- 端口被占用
- 依赖未安装
- 环境变量配置错误

### 7. 前端页面空白

检查：
- 前端是否正确构建
- Nginx 配置是否正确
- 浏览器控制台是否有错误

解决方法：

```bash
# 重新构建前端
cd /www/wwwroot/minilpa-web
npm run build

# 检查构建产物
ls -la client/dist

# 重载 Nginx
nginx -s reload
```

## 性能优化

### 1. 启用 Gzip 压缩

在 Nginx 配置中已包含 Gzip 配置。

### 2. 启用浏览器缓存

在 Nginx 配置中添加：

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. 使用 CDN

将静态资源上传到 CDN，修改前端配置使用 CDN 地址。

### 4. PM2 集群模式

```bash
pm2 start server/index.js --name minilpa-web -i max
```

## 安全建议

1. **定期更新**：保持系统和软件包最新
2. **防火墙配置**：只开放必要的端口
3. **使用 HTTPS**：配置 SSL 证书
4. **修改默认端口**：修改宝塔面板和 SSH 默认端口
5. **备份数据**：定期备份数据库文件
6. **监控日志**：定期检查应用和系统日志

## 备份和恢复

### 备份

```bash
# 备份数据
cd /www/wwwroot/minilpa-web
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# 备份到远程
scp backup-*.tar.gz user@backup-server:/backup/
```

### 恢复

```bash
cd /www/wwwroot/minilpa-web
tar -xzf backup-20240101.tar.gz
pm2 restart minilpa-web
```

## 技术支持

如遇问题，请查看：
- [项目文档](../README.md)
- [Issues](https://github.com/your-repo/issues)

---

**祝部署顺利！** 🎉

