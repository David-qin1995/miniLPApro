# 🐳 宝塔环境 Docker 部署说明

## 📋 问题说明

在宝塔环境中使用 Docker 时，需要注意：

1. **端口冲突**：宝塔 Nginx 已占用 80/443 端口
2. **平台架构**：Mac ARM64 构建的镜像需要在 AMD64 服务器运行

---

## ✅ 解决方案

### 问题 1: 端口冲突

**解决**：使用 `docker-compose.image-baota.yml` 配置
- ✅ 不暴露 80/443 端口
- ✅ 由宝塔 Nginx 直接代理到容器内应用
- ✅ 避免端口冲突

### 问题 2: 平台不匹配

**解决**：使用多平台构建
- ✅ Dockerfile 指定 `--platform=linux/amd64`
- ✅ 确保镜像兼容 x86_64 服务器

---

## 🚀 部署步骤

### 方式一：使用宝塔专用配置（推荐）⭐⭐⭐⭐⭐

```bash
cd /www/wwwroot/minilpa-web

# 使用宝塔专用配置（不启动 Nginx 容器）
docker-compose -f docker-compose.image-baota.yml up -d minilpa-web
```

**优点**：
- ✅ 不占用 80/443 端口
- ✅ 与宝塔 Nginx 完美配合
- ✅ 配置简单

---

### 方式二：使用自动检测脚本

```bash
cd /www/wwwroot/minilpa-web
bash docker-pull-deploy.sh
```

脚本会自动检测：
- ✅ 如果 80/443 被占用，使用宝塔配置
- ✅ 如果端口空闲，使用标准配置

---

### 方式三：手动配置

#### 步骤 1: 拉取镜像

```bash
docker pull jasonqin95/minilpa-web:latest
```

#### 步骤 2: 启动应用容器（不启动 Nginx）

```bash
docker-compose -f docker-compose.image-baota.yml up -d minilpa-web
```

#### 步骤 3: 配置宝塔 Nginx

使用 `nginx-baota-traditional.conf` 配置，直接代理到容器：

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3000;  # 直接代理到容器端口
}
```

---

## 📝 配置文件说明

### docker-compose.image-baota.yml

**特点**：
- ✅ `minilpa-web` 暴露 3000 端口
- ✅ `nginx` 容器不暴露端口（或注释掉）
- ✅ 由宝塔 Nginx 直接代理

### docker-compose.image.yml

**特点**：
- ✅ 适用于独立服务器（没有宝塔）
- ✅ 容器内 Nginx 暴露 80/443 端口
- ✅ 完全容器化部署

---

## ⚙️ 宝塔 Nginx 配置

使用 `nginx-baota-traditional.conf`：

```nginx
# 后端 API 代理（直接代理到容器端口）
location /api/ {
    proxy_pass http://127.0.0.1:3000;  # 容器端口
}

# 前端静态文件
location / {
    root /www/wwwroot/minilpa-web/client/dist;
    try_files $uri $uri/ /index.html;
}
```

---

## 🔍 验证部署

### 检查容器状态

```bash
# 查看容器
docker ps | grep minilpa-web

# 应该看到：
# CONTAINER ID   IMAGE                        PORTS                    STATUS
# xxx            jasonqin95/minilpa-web:latest   0.0.0.0:3000->3000/tcp   Up
```

### 测试后端

```bash
# 测试容器内应用
curl http://localhost:3000/api/health

# 测试宝塔 Nginx 代理
curl http://localhost/api/health
```

---

## 🎯 推荐方案

**使用宝塔环境**：
1. ✅ 使用 `docker-compose.image-baota.yml`
2. ✅ 只启动 `minilpa-web` 容器
3. ✅ 配置宝塔 Nginx 代理到 `127.0.0.1:3000`
4. ✅ 前端静态文件由宝塔 Nginx 直接提供

**优点**：
- ✅ 避免端口冲突
- ✅ 利用宝塔 SSL 证书功能
- ✅ 统一管理（宝塔面板）

---

## 🚨 故障排查

### 问题 1: 端口已被占用

**错误**：`bind: address already in use`

**解决**：
```bash
# 使用宝塔专用配置
docker-compose -f docker-compose.image-baota.yml up -d minilpa-web

# 或检查占用端口的进程
lsof -i:80
lsof -i:443
```

---

### 问题 2: 平台不匹配警告

**警告**：`platform (linux/arm64/v8) does not match (linux/amd64/v4)`

**解决**：
1. 重新构建镜像（指定平台）：
   ```bash
   docker build --platform linux/amd64 -t jasonqin95/minilpa-web:latest .
   ```

2. 或使用多平台构建：
   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 -t jasonqin95/minilpa-web:latest .
   ```

---

## ✅ 完整部署命令

```bash
# 1. 进入项目目录
cd /www/wwwroot/minilpa-web

# 2. 配置环境变量
cp env.esim.haoyiseo.com .env

# 3. 拉取镜像
docker pull jasonqin95/minilpa-web:latest

# 4. 启动应用容器（使用宝塔配置）
docker-compose -f docker-compose.image-baota.yml up -d minilpa-web

# 5. 查看状态
docker ps | grep minilpa-web

# 6. 测试
curl http://localhost:3000/api/health

# 7. 配置宝塔 Nginx（使用 nginx-baota-traditional.conf）
# 在宝塔面板中应用配置
```

---

## 📊 架构对比

### 标准部署（docker-compose.image.yml）

```
Internet → Docker Nginx (80/443) → minilpa-web (3000)
```

### 宝塔部署（docker-compose.image-baota.yml）

```
Internet → 宝塔 Nginx (80/443) → minilpa-web (3000)
```

---

## 🎯 推荐配置

**宝塔环境**：
- ✅ 使用 `docker-compose.image-baota.yml`
- ✅ 只运行应用容器
- ✅ 宝塔 Nginx 负责反向代理和 SSL

**独立服务器**：
- ✅ 使用 `docker-compose.image.yml`
- ✅ 容器内 Nginx 处理所有请求

---

**使用宝塔专用配置，完美解决端口冲突问题！** 🚀

