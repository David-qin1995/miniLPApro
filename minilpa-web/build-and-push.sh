#!/bin/bash

# ========================================
# 构建并推送 Docker 镜像到仓库
# ========================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
IMAGE_NAME="davidqin1995/minilpa-web"  # Docker Hub 用户名/镜像名
# 或使用国内镜像仓库
# IMAGE_NAME="registry.cn-hangzhou.aliyuncs.com/your-namespace/minilpa-web"
VERSION="${1:-latest}"  # 版本号，默认为 latest

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🐳 构建并推送 Docker 镜像                                   ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker 未运行，请先启动 Docker${NC}"
    exit 1
fi

echo -e "${BLUE}[1/4] 构建 Docker 镜像...${NC}"
echo "镜像名称: ${IMAGE_NAME}:${VERSION}"
echo ""

# 构建镜像
docker build -t ${IMAGE_NAME}:${VERSION} .
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 镜像构建成功${NC}"
else
    echo -e "${RED}❌ 镜像构建失败${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[2/4] 测试镜像...${NC}"

# 测试镜像是否可以正常启动
docker run --rm -d \
    --name minilpa-test \
    -p 3001:3000 \
    ${IMAGE_NAME}:${VERSION} > /dev/null

sleep 5

if curl -f http://localhost:3001/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 镜像测试通过${NC}"
    docker stop minilpa-test > /dev/null
else
    echo -e "${YELLOW}⚠️  镜像测试失败，但继续推送${NC}"
    docker stop minilpa-test > /dev/null 2>&1 || true
fi

echo ""
echo -e "${BLUE}[3/4] 登录 Docker Hub...${NC}"
echo "请输入 Docker Hub 用户名和密码："
docker login

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 登录成功${NC}"
else
    echo -e "${RED}❌ 登录失败${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[4/4] 推送镜像到仓库...${NC}"

# 推送版本标签
docker push ${IMAGE_NAME}:${VERSION}

# 推送 latest 标签
if [ "${VERSION}" != "latest" ]; then
    docker push ${IMAGE_NAME}:latest
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ✅ 镜像推送成功！                                          ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}镜像地址:${NC}"
    echo "  ${IMAGE_NAME}:${VERSION}"
    echo "  ${IMAGE_NAME}:latest"
    echo ""
    echo -e "${YELLOW}在服务器上拉取并运行:${NC}"
    echo "  docker pull ${IMAGE_NAME}:latest"
    echo "  或使用部署脚本: bash docker-pull-deploy.sh"
else
    echo -e "${RED}❌ 镜像推送失败${NC}"
    exit 1
fi

