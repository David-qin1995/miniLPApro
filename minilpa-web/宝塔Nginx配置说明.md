# 📖 宝塔 Nginx 配置说明

## 📋 目录

- [两种部署方式](#两种部署方式)
- [配置对比](#配置对比)
- [使用说明](#使用说明)
- [配置步骤](#配置步骤)

---

## 🎯 两种部署方式

### 方式一：传统部署（PM2）

- **后端**: Node.js + Express 运行在端口 **3000**
- **前端**: 静态文件在 `/www/wwwroot/minilpa-web/client/dist`
- **Nginx**: 反向代理后端 API，直接提供前端静态文件

**配置文件**: `nginx-baota-traditional.conf`

---

### 方式二：Docker 部署（推荐）🐳

- **所有服务**: 运行在 Docker 容器内
- **容器端口**: 80（由 docker-compose 管理）
- **Nginx**: 只做一层反向代理到 Docker 容器

**配置文件**: `nginx-baota-docker.conf`

---

## 📊 配置对比

| 特性 | 传统部署 | Docker 部署 |
|------|---------|------------|
| 后端端口 | 3000 | 80（容器内） |
| 前端路径 | `/www/wwwroot/minilpa-web/client/dist` | 容器内（由 Docker Nginx 处理） |
| 配置复杂度 | ⭐⭐⭐ | ⭐⭐ |
| 环境隔离 | ❌ | ✅ |
| 推荐度 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 📝 使用说明

### 方式一：传统部署配置

#### 1. 复制配置文件

```bash
# 在服务器上执行
cd /www/wwwroot/minilpa-web
cp nginx-baota-traditional.conf /www/server/panel/vhost/nginx/esim.haoyiseo.com.conf
```

#### 2. 修改宝塔面板配置

1. 登录**宝塔面板**
2. 进入 **网站** → 找到 `esim.haoyiseo.com`
3. 点击 **设置** → **配置文件**
4. 粘贴 `nginx-baota-traditional.conf` 的内容
5. 点击 **保存**

#### 3. 测试配置

```bash
# 测试 Nginx 配置
nginx -t

# 重载配置
nginx -s reload
```

#### 4. 配置要点

- ✅ **后端端口**: `http://127.0.0.1:3000`
- ✅ **前端路径**: `/www/wwwroot/minilpa-web/client/dist`
- ✅ **API 代理**: `/api/` → 后端
- ✅ **静态文件**: 直接由 Nginx 提供

---

### 方式二：Docker 部署配置

#### 1. 修改 docker-compose.yml

如果使用 Docker 部署，需要确保容器端口映射正确：

```yaml
services:
  nginx:
    ports:
      - "8080:80"  # 映射到 8080（避免与宝塔 Nginx 冲突）
```

#### 2. 复制配置文件

```bash
# 在服务器上执行
cd /www/wwwroot/minilpa-web
cp nginx-baota-docker.conf /www/server/panel/vhost/nginx/esim.haoyiseo.com.conf
```

#### 3. 修改代理端口

编辑配置文件，将 `proxy_pass http://127.0.0.1:80;` 改为：

```nginx
proxy_pass http://127.0.0.1:8080;  # 与 docker-compose.yml 中的端口一致
```

#### 4. 在宝塔面板中配置

1. 登录**宝塔面板**
2. 进入 **网站** → 找到 `esim.haoyiseo.com`
3. 点击 **设置** → **配置文件**
4. 粘贴修改后的配置内容
5. 点击 **保存**

---

## 🔧 配置步骤

### 步骤 1：选择部署方式

- **推荐**: Docker 部署（解决环境问题）
- **备选**: 传统部署（需要手动安装 Node.js、PM2）

### 步骤 2：准备配置文件

```bash
# 传统部署
cd /www/wwwroot/minilpa-web
cat nginx-baota-traditional.conf

# Docker 部署
cat nginx-baota-docker.conf
```

### 步骤 3：在宝塔面板中应用

1. **登录宝塔面板**
2. **网站** → 找到 `esim.haoyiseo.com`
3. **设置** → **配置文件**
4. **清空现有内容** → **粘贴新配置** → **保存**

### 步骤 4：验证配置

```bash
# 测试 Nginx 配置语法
nginx -t

# 如果成功，重载配置
nginx -s reload

# 或使用宝塔面板
# 网站 → 设置 → 配置文件 → 测试 → 保存
```

### 步骤 5：测试访问

```bash
# 测试后端
curl http://localhost:3000/api/health  # 传统部署
curl http://localhost:8080/api/health  # Docker 部署

# 测试前端
curl http://localhost/

# 测试域名
curl http://esim.haoyiseo.com/api/health
```

---

## 🔍 配置详解

### 传统部署配置要点

```nginx
# 1. 前端静态文件目录
root /www/wwwroot/minilpa-web/client/dist;

# 2. 后端 API 代理
location /api/ {
    proxy_pass http://127.0.0.1:3000;
}

# 3. Vue Router 支持
location / {
    try_files $uri $uri/ /index.html;
}
```

### Docker 部署配置要点

```nginx
# 所有请求代理到 Docker 容器
location / {
    proxy_pass http://127.0.0.1:8080;  # 与 docker-compose.yml 端口一致
}
```

---

## ⚠️ 注意事项

### 1. 端口冲突

- **传统部署**: 确保后端运行在端口 **3000**
- **Docker 部署**: 确保容器映射到端口 **8080**（或其他非 80 端口）

### 2. 路径问题

- **传统部署**: 前端路径必须是 `/www/wwwroot/minilpa-web/client/dist`
- **Docker 部署**: 前端路径不需要配置，由容器处理

### 3. SSL 证书

申请 SSL 证书后，宝塔会自动添加 HTTPS 配置，无需手动修改。

### 4. WebSocket（如果需要）

如果项目需要 WebSocket，在配置中添加：

```nginx
location /ws {
    proxy_pass http://127.0.0.1:3000;  # 或 8080（Docker）
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

---

## 🚀 推荐配置

### 方案一：Docker 部署（推荐）⭐⭐⭐⭐⭐

**优点**：
- ✅ 环境一致性好
- ✅ 配置简单（只需一层代理）
- ✅ 易于维护和升级

**配置**：
```bash
# 1. 使用 Docker 部署
bash docker-deploy.sh

# 2. 修改 docker-compose.yml，将 Nginx 端口改为 8080
ports:
  - "8080:80"

# 3. 使用 nginx-baota-docker.conf 配置
```

### 方案二：传统部署

**优点**：
- ✅ 直接访问静态文件（性能好）
- ✅ 可以单独优化静态文件缓存

**配置**：
```bash
# 1. 使用传统方式部署
bash 一键部署到esim.haoyiseo.com.sh

# 2. 使用 nginx-baota-traditional.conf 配置
```

---

## ✅ 配置检查清单

- [ ] 已选择部署方式（传统/Docker）
- [ ] 已复制对应的配置文件
- [ ] 已修改代理端口（Docker 部署需要）
- [ ] 已修改前端路径（传统部署需要）
- [ ] 已在宝塔面板中应用配置
- [ ] Nginx 配置测试通过
- [ ] 已重载 Nginx 配置
- [ ] 后端 API 可访问
- [ ] 前端页面可访问
- [ ] SSL 证书已配置（可选但推荐）

---

## 📞 故障排查

### 问题 1：502 Bad Gateway

```bash
# 检查后端是否运行
# 传统部署
pm2 status
curl http://localhost:3000/api/health

# Docker 部署
docker-compose ps
curl http://localhost:8080/api/health
```

### 问题 2：404 Not Found（前端）

```bash
# 检查前端文件是否存在
ls -la /www/wwwroot/minilpa-web/client/dist/index.html

# 检查 Nginx 配置中的 root 路径是否正确
nginx -T | grep root
```

### 问题 3：API 请求失败

```bash
# 检查代理配置
nginx -T | grep -A 10 "location /api"

# 测试后端连接
curl http://127.0.0.1:3000/api/health  # 传统部署
curl http://127.0.0.1:8080/api/health  # Docker 部署
```

---

**选择适合您的部署方式，然后应用对应的配置文件！** 🚀

