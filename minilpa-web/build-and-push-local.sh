#!/bin/bash

# ========================================
# 本地构建前端后推送 Docker 镜像到仓库
# ========================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
IMAGE_NAME="jasonqin95/minilpa-web"  # Docker Hub 用户名/镜像名
VERSION="${1:-latest}"  # 版本号，默认为 latest

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🐳 本地构建前端并推送 Docker 镜像                            ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 检查是否在项目目录
if [ ! -f "Dockerfile.local-build" ]; then
    echo -e "${RED}❌ 错误：请在项目根目录运行此脚本！${NC}"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/5] 检查前端构建..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查前端是否已构建
if [ ! -d "client/dist" ] || [ -z "$(ls -A client/dist)" ]; then
    echo -e "${YELLOW}⚠️  前端未构建，开始构建前端...${NC}"
    echo ""
    
    cd client
    
    # 检查是否有 node_modules
    if [ ! -d "node_modules" ]; then
        echo -e "${BLUE}📦 安装前端依赖...${NC}"
        npm install --silent
    fi
    
    # 构建前端
    echo -e "${BLUE}🔨 构建前端...${NC}"
    npm run build
    
    cd ..
    
    if [ ! -d "client/dist" ] || [ -z "$(ls -A client/dist)" ]; then
        echo -e "${RED}❌ 前端构建失败！${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 前端构建完成${NC}"
else
    echo -e "${GREEN}✅ 前端已构建${NC}"
    echo ""
    echo "前端文件："
    ls -lh client/dist/ | head -5
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/5] 清理旧镜像..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker rmi ${IMAGE_NAME}:${VERSION} 2>/dev/null || echo "⚠️  旧镜像不存在，跳过清理"
docker rmi ${IMAGE_NAME}:v1.0.0 2>/dev/null || echo "⚠️  旧镜像不存在，跳过清理"

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/5] 构建 Docker 镜像（使用本地构建的前端）..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 构建 AMD64 镜像（使用本地构建版本）
docker build --platform linux/amd64 -f Dockerfile.local-build -t ${IMAGE_NAME}:${VERSION} .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 镜像构建成功${NC}"
else
    echo -e "${RED}❌ 镜像构建失败${NC}"
    exit 1
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/5] 标记版本..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:v1.0.0

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 版本标记完成${NC}"
    echo ""
    docker images | grep "${IMAGE_NAME}"
else
    echo -e "${RED}❌ 版本标记失败${NC}"
    exit 1
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[5/5] 登录并推送镜像..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否已登录
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}⚠️  未登录 Docker Hub，请登录...${NC}"
    docker login
fi

echo -e "${BLUE}📤 推送镜像...${NC}"
docker push ${IMAGE_NAME}:${VERSION}
docker push ${IMAGE_NAME}:v1.0.0

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 镜像推送成功${NC}"
else
    echo -e "${RED}❌ 镜像推送失败${NC}"
    exit 1
fi

echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ 本地构建并推送完成！                                     ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 镜像列表："
echo "  • ${IMAGE_NAME}:${VERSION}"
echo "  • ${IMAGE_NAME}:v1.0.0"
echo ""
echo "🌐 查看镜像: https://hub.docker.com/r/${IMAGE_NAME}/tags"
echo ""
echo "💡 优势："
echo "  ✅ 构建速度快（前端在本地构建）"
echo "  ✅ 镜像更小（不需要构建工具）"
echo "  ✅ 可以利用本地缓存"
echo ""

