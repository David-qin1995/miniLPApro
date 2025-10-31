#!/bin/bash

# ========================================
# 服务器端快速修复脚本
# 解决 docker-compose.image-baota.yml 不存在的问题
# ========================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🔧 服务器端快速修复                                           ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 检查是否在项目目录
if [ ! -f "docker-compose.image.yml" ]; then
    echo -e "${RED}❌ 错误：请在项目根目录运行此脚本！${NC}"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/3] 检查文件..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 docker-compose.image-baota.yml 是否存在
if [ ! -f "docker-compose.image-baota.yml" ]; then
    echo -e "${YELLOW}⚠️  docker-compose.image-baota.yml 不存在${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[2/3] 尝试拉取最新代码..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ -d ".git" ]; then
        echo -e "${BLUE}📥 拉取最新代码...${NC}"
        git pull origin main
        
        # 再次检查
        if [ -f "docker-compose.image-baota.yml" ]; then
            echo -e "${GREEN}✅ 文件已获取${NC}"
        else
            echo -e "${YELLOW}⚠️  拉取后文件仍不存在，创建临时配置...${NC}"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "[3/3] 创建临时宝塔配置..."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            # 从标准配置创建宝塔配置（只启动应用容器）
            cat > docker-compose.image-baota.yml << 'EOF'
version: '3.8'

services:
  # MiniLPA Web 应用（从镜像仓库拉取）
  minilpa-web:
    # 使用镜像而不是构建
    image: jasonqin95/minilpa-web:latest
    container_name: minilpa-web
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - CORS_ORIGIN=https://esim.haoyiseo.com
      - USE_MOCK_DATA=true
    volumes:
      # 持久化数据
      - ./data:/app/data
      - ./logs:/app/logs
      - ./uploads:/app/uploads
      # 环境变量文件
      - ./.env:/app/.env:ro
    networks:
      - minilpa-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  minilpa-network:
    driver: bridge
EOF
            
            echo -e "${GREEN}✅ 临时配置已创建${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  不是 Git 仓库，创建临时配置...${NC}"
        # 创建临时配置（同上）
        cat > docker-compose.image-baota.yml << 'EOF'
version: '3.8'

services:
  minilpa-web:
    image: jasonqin95/minilpa-web:latest
    container_name: minilpa-web
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - CORS_ORIGIN=https://esim.haoyiseo.com
      - USE_MOCK_DATA=true
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
      - ./uploads:/app/uploads
      - ./.env:/app/.env:ro
    networks:
      - minilpa-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  minilpa-network:
    driver: bridge
EOF
        
        echo -e "${GREEN}✅ 临时配置已创建${NC}"
    fi
else
    echo -e "${GREEN}✅ docker-compose.image-baota.yml 已存在${NC}"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ 修复完成！                                               ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 下一步："
echo "  bash docker-pull-deploy.sh"
echo ""

