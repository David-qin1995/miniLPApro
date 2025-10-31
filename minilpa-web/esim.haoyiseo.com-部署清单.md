# 🎯 esim.haoyiseo.com 部署清单

## 📋 项目信息

- **项目名称**: MiniLPA Web
- **域名**: esim.haoyiseo.com
- **部署路径**: /www/wwwroot/minilpa
- **服务器**: CentOS 7 + 宝塔面板
- **后端端口**: 3000
- **前端**: 静态文件 (Nginx)

---

## 📁 专属配置文件

### ✅ 已为您准备的文件

| 文件名 | 说明 | 用途 |
|--------|------|------|
| `一键部署到esim.haoyiseo.com.sh` | 一键部署脚本 | **推荐使用** |
| `nginx-esim.haoyiseo.com.conf` | Nginx 配置 | 复制到服务器 |
| `env.esim.haoyiseo.com` | 环境变量 | 部署时重命名为 `.env` |
| `部署到esim.haoyiseo.com.md` | 详细指南 | 部署前阅读 |
| `scripts/baota-deploy.sh` | 通用部署脚本 | 已配置域名 |

所有文件中的域名已配置为 **esim.haoyiseo.com** ✓

---

## 🚀 部署步骤

### 方式一：一键部署（推荐）⭐

```bash
# 1. SSH 登录服务器
ssh root@your-server-ip

# 2. 进入宝塔目录
cd /www/wwwroot

# 3. 克隆项目
git clone https://github.com/your-username/minilpa.git minilpa
# 或使用其他方式上传项目文件

# 4. 进入项目
cd minilpa

# 5. 一键部署
bash 一键部署到esim.haoyiseo.com.sh
```

### 方式二：使用通用脚本

```bash
cd /www/wwwroot/minilpa
bash scripts/baota-deploy.sh
```

---

## ⚙️ 配置说明

### 1. 环境变量配置

部署脚本会自动复制 `env.esim.haoyiseo.com` 到 `.env`

**重要配置项**：
```bash
PORT=3000                                    # 后端端口
CORS_ORIGIN=https://esim.haoyiseo.com      # 前端域名（重要！）
USE_MOCK_DATA=true                          # 使用模拟数据
```

### 2. Nginx 配置

自动复制 `nginx-esim.haoyiseo.com.conf` 到：
```
/www/server/panel/vhost/nginx/minilpa.conf
```

**关键配置**：
- `server_name`: esim.haoyiseo.com
- 前端静态文件: `/www/wwwroot/minilpa/client/dist`
- API 反向代理: `http://127.0.0.1:3000`

### 3. PM2 配置

自动使用项目中的 `ecosystem.config.js`

**进程名**: minilpa

---

## 🌐 DNS 配置

### 需要添加的 DNS 记录

| 主机记录 | 记录类型 | 记录值 |
|----------|---------|--------|
| esim | A | 您的服务器IP |

### 验证 DNS 解析

```bash
# 方式一
nslookup esim.haoyiseo.com

# 方式二
ping esim.haoyiseo.com

# 方式三
dig esim.haoyiseo.com
```

---

## 🔒 SSL 证书配置（必需！）

### 方式一：宝塔面板（推荐）

1. 登录宝塔面板
2. 网站 → 找到站点 → 设置
3. SSL → Let's Encrypt
4. 输入邮箱
5. 点击申请
6. **开启强制 HTTPS** ✓

### 方式二：命令行

```bash
# 安装 certbot
yum install -y certbot

# 申请证书
certbot certonly --webroot \
  -w /www/wwwroot/minilpa/client/dist \
  -d esim.haoyiseo.com \
  --email your-email@example.com

# 证书位置
# /etc/letsencrypt/live/esim.haoyiseo.com/fullchain.pem
# /etc/letsencrypt/live/esim.haoyiseo.com/privkey.pem
```

---

## ✅ 部署后验证

### 1. 检查服务状态

```bash
# PM2 进程
pm2 status

# 应该看到：
# ┌─────┬────────┬─────────┬──────┐
# │ id  │ name   │ status  │ cpu  │
# ├─────┼────────┼─────────┼──────┤
# │ 0   │ minilpa│ online  │ 0%   │
# └─────┴────────┴─────────┴──────┘

# 后端健康检查
curl http://localhost:3000/api/health

# 应该返回：{"status":"ok"}

# Nginx 配置
nginx -t

# 应该返回：nginx: configuration file test is successful
```

### 2. 浏览器访问

- HTTP: http://esim.haoyiseo.com
- HTTPS: https://esim.haoyiseo.com （配置 SSL 后）

### 3. 检查日志

```bash
# PM2 日志
pm2 logs minilpa

# Nginx 访问日志
tail -f /www/wwwroot/minilpa/logs/nginx-access.log

# Nginx 错误日志
tail -f /www/wwwroot/minilpa/logs/nginx-error.log
```

---

## 🔍 故障排查

### 问题 1: 域名无法访问

**可能原因**：
- DNS 未生效
- 防火墙未开放端口
- Nginx 未启动

**解决方案**：
```bash
# 检查 DNS
nslookup esim.haoyiseo.com

# 检查防火墙
firewall-cmd --list-ports

# 开放端口
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# 检查 Nginx
systemctl status nginx
nginx -t
```

### 问题 2: 502 Bad Gateway

**可能原因**：
- 后端未启动
- 端口被占用
- PM2 进程异常

**解决方案**：
```bash
# 检查 PM2
pm2 status
pm2 logs minilpa

# 检查端口
lsof -i:3000

# 重启服务
pm2 restart minilpa
```

### 问题 3: CORS 错误

**可能原因**：
- `.env` 中的 `CORS_ORIGIN` 配置错误

**解决方案**：
```bash
# 编辑 .env
vim /www/wwwroot/minilpa/.env

# 确保配置正确
CORS_ORIGIN=https://esim.haoyiseo.com

# 重启服务
pm2 restart minilpa
```

### 问题 4: SSL 证书申请失败

**可能原因**：
- DNS 未解析到服务器
- 80 端口未开放
- 域名已有其他证书

**解决方案**：
```bash
# 确保 DNS 已解析
ping esim.haoyiseo.com

# 确保 80 端口可访问
curl http://esim.haoyiseo.com

# 查看 certbot 日志
tail -f /var/log/letsencrypt/letsencrypt.log
```

---

## 🔧 常用管理命令

### PM2 管理

```bash
# 查看状态
pm2 status

# 查看日志
pm2 logs minilpa

# 重启服务
pm2 restart minilpa

# 停止服务
pm2 stop minilpa

# 删除服务
pm2 delete minilpa
```

### Nginx 管理

```bash
# 测试配置
nginx -t

# 重载配置
nginx -s reload

# 重启 Nginx
systemctl restart nginx

# 查看状态
systemctl status nginx
```

### 日志管理

```bash
# 查看 PM2 日志
pm2 logs minilpa

# 清理 PM2 日志
pm2 flush

# 查看 Nginx 日志
tail -f /www/wwwroot/minilpa/logs/nginx-access.log
tail -f /www/wwwroot/minilpa/logs/nginx-error.log
```

---

## 📊 目录结构

```
/www/wwwroot/minilpa/
├── client/                  # 前端代码
│   ├── dist/               # 构建输出（Nginx 指向这里）
│   ├── src/                # 源代码
│   └── package.json
├── server/                 # 后端代码
│   ├── routes/            # API 路由
│   ├── lpac/              # LPAC 集成
│   └── index.js           # 入口文件
├── data/                   # 数据库文件
│   └── db.json
├── logs/                   # 日志文件
│   ├── nginx-access.log
│   └── nginx-error.log
├── uploads/                # 上传文件
├── .env                    # 环境变量（重要！）
├── ecosystem.config.js     # PM2 配置
└── package.json
```

---

## 🛡️ 安全建议

### 必做项

1. ✅ **配置 SSL 证书**
   - 使用 Let's Encrypt 免费证书
   - 开启强制 HTTPS

2. ✅ **修改默认端口**
   - 宝塔面板默认端口 8888
   - SSH 默认端口 22

3. ✅ **配置防火墙**
   ```bash
   # 只开放必要端口
   firewall-cmd --permanent --add-service=http
   firewall-cmd --permanent --add-service=https
   firewall-cmd --permanent --add-port=8888/tcp  # 宝塔面板
   firewall-cmd --reload
   ```

4. ✅ **修改 SESSION_SECRET**
   ```bash
   vim /www/wwwroot/minilpa/.env
   # 修改为随机字符串
   SESSION_SECRET=your-random-secret-string-here
   ```

### 建议项

1. 🔹 定期备份数据
2. 🔹 定期更新系统
3. 🔹 监控服务器资源
4. 🔹 查看访问日志

---

## 💾 备份与恢复

### 备份

```bash
#!/bin/bash
# 创建备份目录
mkdir -p /backup/minilpa

# 备份数据和上传文件
cd /www/wwwroot/minilpa
tar -czf /backup/minilpa/backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  data/ uploads/ .env

# 只保留最近 7 天的备份
find /backup/minilpa -name "backup-*.tar.gz" -mtime +7 -delete
```

### 恢复

```bash
# 解压备份
cd /www/wwwroot/minilpa
tar -xzf /backup/minilpa/backup-YYYYMMDD-HHMMSS.tar.gz

# 重启服务
pm2 restart minilpa
```

---

## 📈 更新应用

```bash
# 1. 进入项目目录
cd /www/wwwroot/minilpa

# 2. 备份（可选但推荐）
tar -czf ~/minilpa-backup-$(date +%Y%m%d).tar.gz data/ uploads/ .env

# 3. 拉取最新代码
git pull

# 4. 安装依赖
npm install
cd client && npm install && cd ..

# 5. 构建前端
npm run build

# 6. 重启服务
pm2 restart minilpa

# 7. 验证
pm2 logs minilpa
curl http://localhost:3000/api/health
```

---

## 📞 获取帮助

### 📖 文档

- **详细部署指南**: `部署到esim.haoyiseo.com.md`
- **宝塔部署文档**: `宝塔部署指南.md`
- **快速参考**: `快速部署到宝塔.txt`
- **LPAC 配置**: `LPAC配置说明.md`

### 🔧 工具

- **一键部署**: `bash 一键部署到esim.haoyiseo.com.sh`
- **通用部署**: `bash scripts/baota-deploy.sh`
- **命令清单**: `部署命令清单.sh`

---

## ✅ 部署检查清单

部署完成后，请逐项检查：

- [ ] 项目已上传到 `/www/wwwroot/minilpa`
- [ ] 依赖已全部安装（前端 + 后端）
- [ ] `.env` 配置正确
  - [ ] `CORS_ORIGIN=https://esim.haoyiseo.com`
  - [ ] `SESSION_SECRET` 已修改
- [ ] PM2 进程正常运行
  - [ ] `pm2 status` 显示 online
  - [ ] `pm2 logs` 无错误
- [ ] Nginx 配置正确
  - [ ] `nginx -t` 测试通过
  - [ ] `server_name esim.haoyiseo.com`
- [ ] DNS 已正确解析
  - [ ] `ping esim.haoyiseo.com` 成功
- [ ] SSL 证书已配置
  - [ ] `https://esim.haoyiseo.com` 可访问
  - [ ] 强制 HTTPS 已开启
- [ ] 防火墙已配置
  - [ ] 80 端口已开放
  - [ ] 443 端口已开放
- [ ] 后端服务正常
  - [ ] `curl http://localhost:3000/api/health` 返回 OK
- [ ] 前端可访问
  - [ ] 浏览器打开 `https://esim.haoyiseo.com`
  - [ ] 页面加载正常，无控制台错误

---

## 🎉 完成！

恭喜！您的 MiniLPA 项目已成功部署到 **esim.haoyiseo.com**！

### 访问地址

- 🌐 HTTP: http://esim.haoyiseo.com
- 🔒 HTTPS: https://esim.haoyiseo.com

### 下一步

1. ✅ 测试所有功能
2. ✅ 配置定期备份
3. ✅ 监控服务器性能
4. ✅ 查看访问日志

---

**部署时间**: 2025-10-31  
**域名**: esim.haoyiseo.com  
**部署路径**: /www/wwwroot/minilpa  

祝使用愉快！🚀

