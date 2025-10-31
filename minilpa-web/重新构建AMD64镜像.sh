#!/bin/bash

# ========================================
# 重新构建 AMD64 镜像（兼容服务器）
# ========================================

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🐳 重新构建 AMD64 镜像（兼容 x86_64 服务器）                ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

IMAGE_NAME="jasonqin95/minilpa-web"
VERSION="latest"

# 检查是否在项目目录
if [ ! -f "Dockerfile" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本！"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/4] 清理旧镜像..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker rmi ${IMAGE_NAME}:${VERSION} 2>/dev/null || echo "⚠️  旧镜像不存在，跳过清理"
docker rmi ${IMAGE_NAME}:v1.0.0 2>/dev/null || echo "⚠️  旧镜像不存在，跳过清理"

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/4] 构建 AMD64 镜像..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 构建 AMD64 镜像
docker build --platform linux/amd64 -t ${IMAGE_NAME}:${VERSION} .

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功"
else
    echo "❌ 镜像构建失败"
    exit 1
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/4] 标记版本..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:v1.0.0

if [ $? -eq 0 ]; then
    echo "✅ 版本标记完成"
    echo ""
    docker images | grep "${IMAGE_NAME}"
else
    echo "❌ 版本标记失败"
    exit 1
fi

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/4] 验证镜像平台..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查镜像平台信息
IMAGE_INFO=$(docker inspect ${IMAGE_NAME}:${VERSION} | grep -A 10 '"Architecture"')
echo "镜像信息："
echo "$IMAGE_INFO" | head -5

ARCH=$(docker inspect ${IMAGE_NAME}:${VERSION} --format='{{.Architecture}}')
OS=$(docker inspect ${IMAGE_NAME}:${VERSION} --format='{{.Os}}')

echo ""
echo "平台: ${OS}/${ARCH}"

if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x86_64" ]; then
    echo "✅ 镜像架构正确（AMD64）"
else
    echo "⚠️  警告：镜像架构为 ${ARCH}，可能不兼容服务器"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ 镜像构建完成！                                           ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 镜像列表："
echo "  • ${IMAGE_NAME}:${VERSION}"
echo "  • ${IMAGE_NAME}:v1.0.0"
echo ""
echo "🚀 下一步："
echo "  1. 登录 Docker Hub: docker login"
echo "  2. 推送镜像: bash 推送镜像到jasonqin95.sh"
echo "  或手动推送:"
echo "    docker push ${IMAGE_NAME}:${VERSION}"
echo "    docker push ${IMAGE_NAME}:v1.0.0"
echo ""

