#!/bin/bash

# ========================================
# 推送镜像到 jasonqin95 仓库
# ========================================

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🐳 推送镜像到 jasonqin95/minilpa-web                         ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 1. Tag 镜像
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/4] 给镜像打 Tag..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker tag davidqin1995/minilpa-web:latest jasonqin95/minilpa-web:latest
docker tag davidqin1995/minilpa-web:v1.0.0 jasonqin95/minilpa-web:v1.0.0

if [ $? -eq 0 ]; then
    echo "✅ Tag 完成"
    echo ""
    docker images | grep "jasonqin95/minilpa-web"
else
    echo "❌ Tag 失败"
    exit 1
fi

echo ""

# 2. 登录 Docker Hub
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/4] 登录 Docker Hub..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker login

if [ $? -eq 0 ]; then
    echo "✅ 登录成功"
else
    echo "❌ 登录失败"
    exit 1
fi

echo ""

# 3. 推送镜像
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/4] 推送镜像到 Docker Hub..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker push jasonqin95/minilpa-web:latest
docker push jasonqin95/minilpa-web:v1.0.0

if [ $? -eq 0 ]; then
    echo "✅ 推送成功"
else
    echo "❌ 推送失败"
    exit 1
fi

echo ""

# 4. 验证推送
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/4] 验证推送..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

bash check-image.sh jasonqin95/minilpa-web latest

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ 镜像推送完成！                                           ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 镜像地址:"
echo "  • jasonqin95/minilpa-web:latest"
echo "  • jasonqin95/minilpa-web:v1.0.0"
echo ""
echo "📦 在服务器上拉取:"
echo "  docker pull jasonqin95/minilpa-web:latest"
echo "  或使用部署脚本: bash docker-pull-deploy.sh"
echo ""

