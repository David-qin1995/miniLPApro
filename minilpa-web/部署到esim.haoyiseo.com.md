# 🚀 部署到 esim.haoyiseo.com

## 📋 部署信息

- **域名**: esim.haoyiseo.com
- **部署路径**: /www/wwwroot/minilpa
- **服务器**: CentOS 7 + 宝塔面板

---

## ⚡ 一键部署（最快）

### 在服务器上执行：

```bash
# 1. SSH 登录服务器
ssh root@your-server-ip

# 2. 进入宝塔目录
cd /www/wwwroot

# 3. 克隆项目
git clone <your-repository-url> minilpa

# 4. 进入项目
cd minilpa

# 5. 一键部署（域名已配置好）
bash scripts/baota-deploy.sh
```

**域名已自动配置为 `esim.haoyiseo.com`** ✅

---

## 📝 部署后检查

### 1. 验证环境变量

```bash
cat /www/wwwroot/minilpa/.env
```

确认包含：
```
CORS_ORIGIN=https://esim.haoyiseo.com
```

### 2. 验证 Nginx 配置

```bash
cat /www/server/panel/vhost/nginx/minilpa.conf
```

确认包含：
```
server_name esim.haoyiseo.com;
```

### 3. 验证服务状态

```bash
# 检查 PM2
pm2 status

# 检查后端
curl http://localhost:3000/api/health

# 检查 Nginx
nginx -t
```

### 4. 浏览器访问

打开：`http://esim.haoyiseo.com`

---

## 🔒 配置 SSL 证书（重要！）

### 方式一：使用宝塔面板（推荐）

1. 登录宝塔面板
2. 进入 "网站" 
3. 找到 `esim.haoyiseo.com` 站点
4. 点击 "设置" → "SSL"
5. 选择 "Let's Encrypt"
6. 填写邮箱地址
7. 点击 "申请"
8. 开启 "强制HTTPS"

### 方式二：使用命令行

```bash
# 安装 certbot
yum install -y certbot

# 申请证书
certbot certonly --webroot \
  -w /www/wwwroot/minilpa/client/dist \
  -d esim.haoyiseo.com

# 证书路径：
# /etc/letsencrypt/live/esim.haoyiseo.com/fullchain.pem
# /etc/letsencrypt/live/esim.haoyiseo.com/privkey.pem
```

---

## 🌐 DNS 配置

确保域名已正确解析：

```bash
# 检查 DNS 解析
nslookup esim.haoyiseo.com

# 或
dig esim.haoyiseo.com
```

**需要添加 A 记录：**
- 主机记录: `esim`
- 记录类型: `A`
- 记录值: `your-server-ip`

---

## 📊 完整部署流程

```
1. 准备服务器
   ├─ CentOS 7
   ├─ 宝塔面板
   └─ Nginx + PM2 + Node.js
   
2. 配置 DNS
   └─ esim.haoyiseo.com → 服务器 IP
   
3. 部署项目
   ├─ 上传到 /www/wwwroot/minilpa
   └─ 运行 bash scripts/baota-deploy.sh
   
4. 配置 SSL
   └─ 申请 Let's Encrypt 证书
   
5. ✅ 完成
   └─ 访问 https://esim.haoyiseo.com
```

---

## 🔧 配置文件位置

| 文件 | 位置 |
|------|------|
| 环境变量 | `/www/wwwroot/minilpa/.env` |
| Nginx 配置 | `/www/server/panel/vhost/nginx/minilpa.conf` |
| PM2 配置 | `/www/wwwroot/minilpa/ecosystem.config.js` |
| 数据库 | `/www/wwwroot/minilpa/data/db.json` |
| 上传文件 | `/www/wwwroot/minilpa/uploads/` |
| 日志 | `/www/wwwroot/minilpa/logs/` |

---

## 📋 常用命令

### 查看服务状态

```bash
pm2 status
pm2 logs minilpa
```

### 重启服务

```bash
pm2 restart minilpa
nginx -s reload
```

### 查看日志

```bash
# 应用日志
pm2 logs minilpa

# Nginx 日志
tail -f /www/wwwroot/minilpa/logs/nginx-access.log
tail -f /www/wwwroot/minilpa/logs/nginx-error.log
```

### 更新应用

```bash
cd /www/wwwroot/minilpa
git pull
npm install && cd client && npm install && cd ..
npm run build
pm2 restart minilpa
```

---

## ✅ 部署检查清单

部署完成后确认：

- [ ] 项目已上传到 `/www/wwwroot/minilpa`
- [ ] 依赖已全部安装
- [ ] `.env` 配置正确（域名为 esim.haoyiseo.com）
- [ ] PM2 进程正常运行
- [ ] Nginx 配置正确
- [ ] DNS 已正确解析
- [ ] SSL 证书已配置
- [ ] 强制 HTTPS 已开启
- [ ] 防火墙已开放 80/443 端口
- [ ] 浏览器可正常访问

---

## 🎯 访问地址

部署完成后访问：

- **HTTP**: http://esim.haoyiseo.com
- **HTTPS**: https://esim.haoyiseo.com（配置 SSL 后）

**推荐使用 HTTPS！**

---

## 🔐 安全建议

1. ✅ 配置 SSL 证书（必需）
2. ✅ 开启强制 HTTPS
3. ✅ 修改宝塔面板默认端口
4. ✅ 配置防火墙规则
5. ✅ 定期备份数据
6. ✅ 定期更新系统

---

## 💾 备份数据

```bash
# 备份数据
tar -czf ~/minilpa-backup-$(date +%Y%m%d).tar.gz \
  /www/wwwroot/minilpa/data \
  /www/wwwroot/minilpa/uploads

# 或使用自动备份脚本
bash /www/wwwroot/minilpa/scripts/backup.sh
```

---

## ❌ 常见问题

### 域名无法访问

1. 检查 DNS 是否生效：`nslookup esim.haoyiseo.com`
2. 检查防火墙：`firewall-cmd --list-ports`
3. 检查 Nginx：`nginx -t`
4. 检查 PM2：`pm2 status`

### SSL 证书申请失败

1. 确保域名已解析
2. 确保 80 端口开放
3. 检查 Nginx 配置是否正确

### 502 错误

1. 检查后端是否运行：`pm2 status`
2. 检查端口：`lsof -i:3000`
3. 查看日志：`pm2 logs minilpa`

---

## 📞 获取帮助

- 📖 详细文档: `宝塔部署指南.md`
- ⚡ 快速参考: `快速部署到宝塔.txt`
- 📋 命令清单: `部署命令清单.sh`

---

**针对 esim.haoyiseo.com 的部署方案已准备完成！** 🎉

现在就可以开始部署了！🚀

