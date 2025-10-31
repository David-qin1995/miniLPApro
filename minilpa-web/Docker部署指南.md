# 🐳 MiniLPA Docker 容器化部署指南

## 📋 目录

- [为什么使用 Docker](#为什么使用-docker)
- [前置要求](#前置要求)
- [快速开始](#快速开始)
- [详细部署步骤](#详细部署步骤)
- [配置说明](#配置说明)
- [常用命令](#常用命令)
- [故障排查](#故障排查)
- [性能优化](#性能优化)

---

## 🎯 为什么使用 Docker

### ✅ 优势

1. **环境一致性**
   - 开发、测试、生产环境完全一致
   - 不受宿主机系统限制（解决 CentOS 7 glibc 版本问题）
   - 不需要手动安装 Node.js、PM2 等依赖

2. **简化部署**
   - 一条命令完成部署
   - 自动构建、启动、健康检查
   - 轻松回滚和升级

3. **资源隔离**
   - 应用之间互不影响
   - 资源限制和监控
   - 更好的安全性

4. **易于扩展**
   - 水平扩展简单
   - 负载均衡容易实现
   - 支持 K8s 等编排工具

---

## 📦 前置要求

### 服务器要求

- **操作系统**: CentOS 7/8、Ubuntu 18.04+、Debian 9+ 等
- **内存**: 至少 1GB
- **磁盘**: 至少 5GB 可用空间
- **Docker**: 20.10+ 版本
- **docker-compose**: 1.29+ 版本（或使用 `docker compose`）

### 安装 Docker

```bash
# 快速安装 Docker
curl -fsSL https://get.docker.com | bash -

# 启动 Docker
systemctl start docker
systemctl enable docker

# 验证安装
docker --version
docker-compose --version
```

---

## 🚀 快速开始

### 方式一：一键部署脚本（推荐）

```bash
# 1. 克隆项目
cd /www/wwwroot
git clone https://github.com/David-qin1995/miniLPApro.git temp-minilpa
mv temp-minilpa/minilpa-web minilpa-web
rm -rf temp-minilpa

# 2. 进入项目
cd minilpa-web

# 3. 配置环境变量
cp env.esim.haoyiseo.com .env
# 修改 .env 中的配置（如果需要）

# 4. 一键部署
bash docker-deploy.sh
```

### 方式二：手动部署

```bash
# 1. 配置环境变量
cp .env.example .env
vim .env  # 修改配置

# 2. 启动服务
docker-compose up -d --build

# 3. 查看状态
docker-compose ps
docker-compose logs -f
```

---

## 📖 详细部署步骤

### 1. 准备工作

#### 1.1 安装 Docker（如果未安装）

```bash
# CentOS/RHEL
curl -fsSL https://get.docker.com | bash -

# Ubuntu/Debian
curl -fsSL https://get.docker.com | bash -

# 或使用宝塔面板
# 软件商店 → 搜索 "Docker管理器" → 安装
```

#### 1.2 验证 Docker 安装

```bash
docker --version
docker-compose --version

# 测试 Docker
docker run hello-world
```

### 2. 获取项目代码

```bash
cd /www/wwwroot

# 方式一：Git 克隆
git clone https://github.com/David-qin1995/miniLPApro.git temp-minilpa
mv temp-minilpa/minilpa-web minilpa-web
rm -rf temp-minilpa

# 方式二：直接下载
wget https://github.com/David-qin1995/miniLPApro/archive/main.zip
unzip main.zip
mv miniLPApro-main/minilpa-web minilpa-web

cd minilpa-web
```

### 3. 配置环境变量

```bash
# 复制环境变量模板
cp env.esim.haoyiseo.com .env

# 编辑配置
vim .env
```

**重要配置项**：

```bash
# 域名（必须修改）
CORS_ORIGIN=https://esim.haoyiseo.com

# Session 密钥（建议修改为随机字符串）
SESSION_SECRET=your-random-secret-here

# 是否使用模拟数据
USE_MOCK_DATA=true  # true=模拟，false=真实硬件
```

### 4. 构建和启动

```bash
# 方式一：使用部署脚本（推荐）
bash docker-deploy.sh

# 方式二：使用 docker-compose
docker-compose up -d --build
```

### 5. 验证部署

```bash
# 查看容器状态
docker-compose ps

# 应该看到两个容器：
# - minilpa-web    (运行中)
# - minilpa-nginx  (运行中)

# 查看日志
docker-compose logs -f

# 测试后端
curl http://localhost:3000/api/health

# 测试 Nginx
curl http://localhost/api/health
```

### 6. 配置域名（可选）

#### 方式一：使用宝塔面板

1. 登录宝塔面板
2. 网站 → 添加站点
3. 域名：`esim.haoyiseo.com`
4. 反向代理到：`http://localhost:80`

#### 方式二：手动配置 Nginx

如果服务器上已有 Nginx，配置反向代理：

```nginx
server {
    listen 80;
    server_name esim.haoyiseo.com;
    
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 7. 配置 SSL（推荐）

```bash
# 使用 certbot 申请证书
certbot certonly --webroot \
  -w /www/wwwroot/minilpa-web/client/dist \
  -d esim.haoyiseo.com

# 或在宝塔面板中申请 Let's Encrypt 证书
```

---

## ⚙️ 配置说明

### docker-compose.yml

```yaml
services:
  minilpa-web:
    # 后端服务
    ports:
      - "3000:3000"  # 后端端口
    environment:
      - CORS_ORIGIN=https://esim.haoyiseo.com  # 修改为您的域名
    volumes:
      - ./data:/app/data        # 数据持久化
      - ./logs:/app/logs        # 日志持久化
      - ./uploads:/app/uploads  # 上传文件持久化

  nginx:
    # Nginx 反向代理
    ports:
      - "80:80"    # HTTP 端口
      - "443:443"  # HTTPS 端口（需要配置 SSL）
```

### Dockerfile

多阶段构建：
1. **构建阶段**：编译前端（Vue + Vite）
2. **生产阶段**：运行后端（Node.js + Express + PM2）

### 环境变量（.env）

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `PORT` | 后端端口 | `3000` |
| `NODE_ENV` | 环境 | `production` |
| `CORS_ORIGIN` | 允许的源 | `https://esim.haoyiseo.com` |
| `USE_MOCK_DATA` | 是否使用模拟数据 | `true` |
| `SESSION_SECRET` | Session 密钥 | 需修改 |

---

## 🔧 常用命令

### 容器管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 重新构建并启动
docker-compose up -d --build

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f minilpa-web
docker-compose logs -f nginx

# 进入容器
docker-compose exec minilpa-web sh
docker-compose exec nginx sh
```

### 更新应用

```bash
# 1. 拉取最新代码
cd /www/wwwroot/minilpa-web
git pull

# 2. 重新构建和启动
docker-compose down
docker-compose up -d --build

# 3. 查看日志
docker-compose logs -f
```

### 备份和恢复

```bash
# 备份数据
tar -czf minilpa-backup-$(date +%Y%m%d).tar.gz data/ uploads/

# 恢复数据
tar -xzf minilpa-backup-20231031.tar.gz
docker-compose restart
```

### 清理

```bash
# 停止并删除容器
docker-compose down

# 删除镜像
docker rmi minilpa-web_minilpa-web

# 清理所有未使用的资源
docker system prune -a
```

---

## 🔍 故障排查

### 问题 1：容器无法启动

```bash
# 查看详细日志
docker-compose logs minilpa-web

# 检查配置
docker-compose config

# 重新构建
docker-compose build --no-cache
docker-compose up -d
```

### 问题 2：端口被占用

```bash
# 查看端口占用
lsof -i:3000
lsof -i:80

# 修改 docker-compose.yml 中的端口映射
ports:
  - "8080:3000"  # 改为 8080
```

### 问题 3：健康检查失败

```bash
# 手动测试
curl http://localhost:3000/api/health

# 查看容器内部日志
docker-compose exec minilpa-web pm2 logs

# 检查容器状态
docker inspect minilpa-web | grep Health -A 20
```

### 问题 4：数据丢失

确保使用了数据卷：

```yaml
volumes:
  - ./data:/app/data        # 持久化到宿主机
  - ./logs:/app/logs
  - ./uploads:/app/uploads
```

---

## 🚀 性能优化

### 1. 资源限制

编辑 `docker-compose.yml`：

```yaml
services:
  minilpa-web:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          memory: 256M
```

### 2. 日志轮转

```yaml
services:
  minilpa-web:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 3. 网络优化

```yaml
networks:
  minilpa-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

---

## 📊 监控

### 查看资源使用

```bash
# 实时监控
docker stats

# 查看特定容器
docker stats minilpa-web minilpa-nginx
```

### 日志管理

```bash
# 查看最近100行
docker-compose logs --tail=100

# 实时跟踪
docker-compose logs -f --tail=50

# 查看特定时间
docker-compose logs --since="2023-10-31T10:00:00"
```

---

## ✅ 部署检查清单

- [ ] Docker 已安装并运行
- [ ] docker-compose 已安装
- [ ] 项目代码已下载
- [ ] `.env` 文件已配置
- [ ] `CORS_ORIGIN` 已修改为正确的域名
- [ ] `SESSION_SECRET` 已修改为随机字符串
- [ ] 容器成功启动（`docker-compose ps`）
- [ ] 健康检查通过
- [ ] 后端可访问（`curl http://localhost:3000/api/health`）
- [ ] Nginx 可访问（`curl http://localhost/api/health`）
- [ ] 域名已解析到服务器
- [ ] SSL 证书已配置（可选）
- [ ] 防火墙已开放 80/443 端口

---

## 🎉 总结

### Docker 部署 vs 传统部署

| 特性 | Docker 部署 | 传统部署 |
|------|------------|---------|
| 环境一致性 | ✅ 完美 | ❌ 容易出问题 |
| 部署速度 | ✅ 快速 | ⚠️ 较慢 |
| 依赖管理 | ✅ 自动 | ❌ 手动安装 |
| 系统兼容 | ✅ 任何系统 | ❌ 受限 |
| 回滚 | ✅ 简单 | ⚠️ 复杂 |
| 扩展 | ✅ 容易 | ⚠️ 困难 |

### 优势

1. ✅ **解决 CentOS 7 glibc 版本问题**
2. ✅ **一键部署，简单快速**
3. ✅ **环境隔离，互不影响**
4. ✅ **易于维护和升级**
5. ✅ **生产环境推荐**

---

**推荐使用 Docker 部署！** 🐳

如有问题，请查看日志：`docker-compose logs -f`

