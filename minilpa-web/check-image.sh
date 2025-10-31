#!/bin/bash

# ========================================
# 检查镜像是否已推送到仓库
# ========================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置（与 build-and-push.sh 保持一致）
IMAGE_NAME="${1:-jasonqin95/minilpa-web}"
IMAGE_TAG="${2:-latest}"

FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🔍 检查镜像推送状态                                          ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}镜像信息:${NC}"
echo "  名称: ${IMAGE_NAME}"
echo "  标签: ${IMAGE_TAG}"
echo "  完整名称: ${FULL_IMAGE_NAME}"
echo ""

# 1. 检查本地镜像
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[1/4] 检查本地镜像...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

LOCAL_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^${IMAGE_NAME}:" | grep "${IMAGE_TAG}" | head -1)

if [ -z "$LOCAL_IMAGE" ]; then
    echo -e "${RED}❌ 本地没有找到镜像: ${FULL_IMAGE_NAME}${NC}"
    echo ""
    echo "本地镜像列表："
    docker images | grep "${IMAGE_NAME}" || echo "  没有相关镜像"
else
    echo -e "${GREEN}✅ 本地镜像存在: ${LOCAL_IMAGE}${NC}"
    echo ""
    echo "镜像详情："
    docker images "${FULL_IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
fi

echo ""

# 2. 检查 Docker Hub（如果是 Docker Hub）
if [[ "$IMAGE_NAME" =~ ^[^/]+/[^/]+$ ]] && [[ ! "$IMAGE_NAME" =~ registry\. ]]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[2/4] 检查 Docker Hub...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    REPO_NAME=$(echo "$IMAGE_NAME" | cut -d'/' -f1)
    IMG_NAME=$(echo "$IMAGE_NAME" | cut -d'/' -f2)
    HUB_URL="https://hub.docker.com/v2/repositories/${IMAGE_NAME}/tags/${IMAGE_TAG}/"
    
    echo "检查地址: ${HUB_URL}"
    echo ""
    
    # 使用 curl 检查（需要网络）
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HUB_URL" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ 镜像已存在于 Docker Hub${NC}"
        echo ""
        echo "详细信息："
        curl -s "$HUB_URL" | python3 -m json.tool 2>/dev/null | grep -E "name|last_updated|size" | head -5 || \
        echo "  访问: https://hub.docker.com/r/${IMAGE_NAME}/tags"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo -e "${RED}❌ 镜像不存在于 Docker Hub${NC}"
        echo ""
        echo "可能的原因："
        echo "  • 镜像未推送"
        echo "  • 镜像名称或标签错误"
        echo "  • 仓库为私有，需要登录查看"
    else
        echo -e "${YELLOW}⚠️  无法访问 Docker Hub (HTTP $HTTP_CODE)${NC}"
        echo ""
        echo "请手动访问: https://hub.docker.com/r/${IMAGE_NAME}/tags"
    fi
else
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[2/4] 检查镜像仓库（${IMAGE_NAME}）...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  使用第三方仓库，请手动检查${NC}"
    echo ""
    if [[ "$IMAGE_NAME" =~ registry\.cn-hangzhou\.aliyuncs\.com ]]; then
        echo "阿里云容器镜像服务:"
        echo "  https://cr.console.aliyun.com/"
    elif [[ "$IMAGE_NAME" =~ ccr\.ccs\.tencentyun\.com ]]; then
        echo "腾讯云容器镜像服务:"
        echo "  https://console.cloud.tencent.com/tcr"
    fi
fi

echo ""

# 3. 尝试拉取镜像（验证是否可访问）
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[3/4] 验证镜像可拉取性...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "注意: 此操作会尝试拉取镜像，可能需要一些时间..."
read -p "是否继续？(y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 先删除本地镜像（如果存在），然后拉取
    docker rmi "${FULL_IMAGE_NAME}" 2>/dev/null || true
    
    if docker pull "${FULL_IMAGE_NAME}" 2>&1 | grep -q "not found\|error\|denied"; then
        echo -e "${RED}❌ 镜像无法拉取，可能未推送或权限不足${NC}"
    else
        echo -e "${GREEN}✅ 镜像可以成功拉取！${NC}"
        echo ""
        echo "镜像信息："
        docker images "${FULL_IMAGE_NAME}"
    fi
else
    echo -e "${YELLOW}⚠️  跳过拉取验证${NC}"
fi

echo ""

# 4. 检查镜像标签列表
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[4/4] 检查所有可用标签...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ "$IMAGE_NAME" =~ ^[^/]+/[^/]+$ ]] && [[ ! "$IMAGE_NAME" =~ registry\. ]]; then
    echo "Docker Hub API 查询："
    TAGS_URL="https://hub.docker.com/v2/repositories/${IMAGE_NAME}/tags/"
    TAGS_RESPONSE=$(curl -s "$TAGS_URL" 2>/dev/null || echo "")
    
    if [ ! -z "$TAGS_RESPONSE" ] && echo "$TAGS_RESPONSE" | grep -q "results"; then
        echo -e "${GREEN}可用标签:${NC}"
        echo "$TAGS_RESPONSE" | python3 -m json.tool 2>/dev/null | grep -E '"name"' | head -10 | sed 's/.*"name": "\(.*\)".*/  • \1/' || \
        echo "  使用命令: curl -s ${TAGS_URL} | python3 -m json.tool"
    else
        echo -e "${YELLOW}⚠️  无法获取标签列表${NC}"
        echo ""
        echo "请手动访问: https://hub.docker.com/r/${IMAGE_NAME}/tags"
    fi
else
    echo -e "${YELLOW}⚠️  请手动在对应平台查看标签列表${NC}"
fi

echo ""

# 总结
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  📊 检查完成                                                  ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}快速验证方法:${NC}"
echo ""
echo "1. 浏览器访问:"
if [[ "$IMAGE_NAME" =~ ^[^/]+/[^/]+$ ]] && [[ ! "$IMAGE_NAME" =~ registry\. ]]; then
    echo "   https://hub.docker.com/r/${IMAGE_NAME}/tags"
elif [[ "$IMAGE_NAME" =~ registry\.cn-hangzhou\.aliyuncs\.com ]]; then
    echo "   https://cr.console.aliyun.com/"
fi
echo ""
echo "2. 命令行验证:"
echo "   docker pull ${FULL_IMAGE_NAME}"
echo ""
echo "3. 检查本地镜像:"
echo "   docker images | grep ${IMAGE_NAME}"
echo ""

