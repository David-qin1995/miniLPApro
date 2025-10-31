#!/bin/bash

# ========================================
# 从镜像仓库拉取并部署
# 用于服务器端快速部署
# ========================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
IMAGE_NAME="jasonqin95/minilpa-web"
IMAGE_TAG="${1:-latest}"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🚀 从镜像仓库拉取并部署 MiniLPA                             ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装！${NC}"
    echo ""
    echo "请先安装 Docker："
    echo "  curl -fsSL https://get.docker.com | bash -"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker 未运行，请先启动 Docker${NC}"
    echo ""
    echo "启动 Docker："
    echo "  systemctl start docker"
    echo "  systemctl enable docker"
    exit 1
fi

# 检查 docker-compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ docker-compose 未安装${NC}"
    exit 1
fi

echo -e "${BLUE}📦 镜像信息:${NC}"
echo "  名称: ${IMAGE_NAME}"
echo "  标签: ${IMAGE_TAG}"
echo ""

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env 文件不存在，从示例创建...${NC}"
    if [ -f "env.esim.haoyiseo.com" ]; then
        cp env.esim.haoyiseo.com .env
        echo -e "${GREEN}✅ 已创建 .env 文件${NC}"
    elif [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ 已创建 .env 文件${NC}"
    else
        echo -e "${RED}❌ 找不到环境变量模板文件${NC}"
        exit 1
    fi
    echo -e "${YELLOW}请检查并修改 .env 文件中的配置${NC}"
    echo ""
fi

# 创建必要的目录
echo -e "${BLUE}[1/5] 创建数据目录...${NC}"
mkdir -p data logs uploads logs/nginx
echo -e "${GREEN}✅ 目录创建完成${NC}"
echo ""

# 更新 docker-compose.image.yml 中的镜像名称
if [ -f "docker-compose.image.yml" ]; then
    echo -e "${BLUE}[2/5] 更新镜像配置...${NC}"
    sed -i.bak "s|image:.*minilpa-web.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" docker-compose.image.yml
    echo -e "${GREEN}✅ 配置更新完成${NC}"
    echo ""
fi

# 拉取镜像
echo -e "${BLUE}[3/5] 拉取 Docker 镜像...${NC}"
docker pull ${IMAGE_NAME}:${IMAGE_TAG}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 镜像拉取成功${NC}"
else
    echo -e "${RED}❌ 镜像拉取失败${NC}"
    echo ""
    echo "可能的原因："
    echo "  1. 镜像不存在或未推送"
    echo "  2. 网络连接问题"
    echo "  3. 需要登录 Docker Hub"
    echo ""
    echo "如果使用私有仓库，请先登录："
    echo "  docker login"
    exit 1
fi

echo ""

# 停止旧容器
echo -e "${BLUE}[4/5] 停止旧容器...${NC}"
$DOCKER_COMPOSE -f docker-compose.image.yml down 2>/dev/null || true
$DOCKER_COMPOSE -f docker-compose.image-baota.yml down 2>/dev/null || true
echo -e "${GREEN}✅ 旧容器已停止${NC}"
echo ""

# 启动新容器
echo -e "${BLUE}[5/5] 启动容器...${NC}"

# 检测是否在宝塔环境（80/443 端口被占用时使用宝塔专用配置）
if lsof -i:80 2>/dev/null | grep -q nginx || lsof -i:443 2>/dev/null | grep -q nginx; then
    echo -e "${YELLOW}⚠️  检测到宝塔 Nginx 在使用 80/443 端口，使用宝塔专用配置${NC}"
    
    # 检查宝塔专用配置文件是否存在
    if [ ! -f "docker-compose.image-baota.yml" ]; then
        echo -e "${RED}❌ 错误：docker-compose.image-baota.yml 文件不存在！${NC}"
        echo -e "${YELLOW}💡 解决方案：${NC}"
        echo "  1. 拉取最新代码: git pull origin main"
        echo "  2. 或使用标准配置: docker-compose -f docker-compose.image.yml up -d minilpa-web"
        echo ""
        echo -e "${BLUE}使用标准配置继续...${NC}"
        COMPOSE_FILE="docker-compose.image.yml"
        # 只启动应用容器，不启动 Nginx（由宝塔 Nginx 代理）
        docker-compose -f docker-compose.image.yml up -d minilpa-web
    else
        COMPOSE_FILE="docker-compose.image-baota.yml"
        # 只启动应用容器，不启动 Nginx 容器（由宝塔 Nginx 代理）
        docker-compose -f docker-compose.image-baota.yml up -d minilpa-web
    fi
else
    COMPOSE_FILE="docker-compose.image.yml"
    $DOCKER_COMPOSE -f docker-compose.image.yml up -d
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 容器启动成功${NC}"
else
    echo -e "${RED}❌ 容器启动失败${NC}"
    exit 1
fi

echo ""

# 等待服务启动
echo -e "${BLUE}等待服务启动...${NC}"
sleep 5

# 检查容器状态
echo ""
echo -e "${BLUE}容器状态:${NC}"
if [ -z "$COMPOSE_FILE" ]; then
    COMPOSE_FILE="docker-compose.image.yml"
fi
$DOCKER_COMPOSE -f "$COMPOSE_FILE" ps
echo ""

# 健康检查
echo -e "${BLUE}执行健康检查...${NC}"
sleep 3

if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 后端服务正常${NC}"
else
    echo -e "${YELLOW}⚠️  后端服务健康检查失败${NC}"
fi

if curl -f http://localhost/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Nginx 代理正常${NC}"
else
    echo -e "${YELLOW}⚠️  Nginx 代理健康检查失败${NC}"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ 部署完成！                                               ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}访问地址:${NC}"
echo "  - HTTP:  http://esim.haoyiseo.com"
echo "  - HTTPS: https://esim.haoyiseo.com (配置 SSL 后)"
echo ""
echo -e "${BLUE}常用命令:${NC}"
echo "  查看日志:   $DOCKER_COMPOSE -f docker-compose.image.yml logs -f"
echo "  重启服务:   $DOCKER_COMPOSE -f docker-compose.image.yml restart"
echo "  停止服务:   $DOCKER_COMPOSE -f docker-compose.image.yml down"
echo "  更新镜像:   bash docker-pull-deploy.sh"
echo ""

