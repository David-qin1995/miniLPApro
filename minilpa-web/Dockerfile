# ========================================
# MiniLPA Web - Dockerfile
# 域名: esim.haoyiseo.com
# ========================================

# 构建阶段 - 前端
# 使用多平台支持，指定平台为 linux/amd64（兼容服务器架构）
FROM --platform=linux/amd64 node:16-alpine AS frontend-builder

WORKDIR /app

# 复制 npm 配置文件（如果有）
COPY .npmrc* ./

WORKDIR /app/client

# 复制前端依赖文件（先复制 package 文件，利用 Docker 缓存）
COPY client/package*.json ./

# 复制 .npmrc 配置文件（优先使用配置文件，避免多次 npm config set）
COPY .npmrc* ./

# 安装依赖（使用 .npmrc 配置，更高效）
RUN npm install --silent --prefer-offline --no-audit --no-fund || \
    (npm config set registry https://registry.npmjs.org/ && \
     npm config set fetch-timeout 600000 && \
     npm config set fetch-retry-mintimeout 20000 && \
     npm config set fetch-retry-maxtimeout 120000 && \
     npm install --silent --prefer-offline --no-audit --no-fund)

# 复制前端源码（在依赖安装后复制，最大化缓存利用）
COPY client/ ./

# 构建前端（使用 CI 模式，减少输出）
# 设置环境变量减少构建输出
ENV NODE_ENV=production
ENV CI=true
RUN npm run build 2>&1 | grep -v "DEPRECATION WARNING" || npm run build

# ========================================
# 生产阶段
# 使用多平台支持，指定平台为 linux/amd64（兼容服务器架构）
FROM --platform=linux/amd64 node:16-alpine

# 设置工作目录
WORKDIR /app

# 安装 PM2 全局
RUN npm install -g pm2

# 复制后端依赖文件
COPY package*.json ./

# 复制 npm 配置文件（如果有）
COPY .npmrc* ./

# 安装后端依赖（生产环境，使用 .npmrc 配置，更高效）
RUN npm install --production --silent --prefer-offline --no-audit --no-fund || \
    (npm config set registry https://registry.npmjs.org/ && \
     npm config set fetch-timeout 600000 && \
     npm config set fetch-retry-mintimeout 20000 && \
     npm config set fetch-retry-maxtimeout 120000 && \
     npm install --production --silent --prefer-offline --no-audit --no-fund)

# 复制后端代码
COPY server/ ./server/
COPY ecosystem.config.js ./

# 复制环境变量模板
COPY .env.example ./.env

# 从构建阶段复制前端构建文件
COPY --from=frontend-builder /app/client/dist ./client/dist

# 创建必要的目录
RUN mkdir -p data logs uploads && \
    chown -R node:node /app

# 切换到非 root 用户
USER node

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 启动应用
CMD ["pm2-runtime", "start", "ecosystem.config.js"]

