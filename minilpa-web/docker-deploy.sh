#!/bin/bash

# ========================================
# Docker 容器化部署脚本
# 用于 esim.haoyiseo.com
# ========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🐳 MiniLPA Docker 容器化部署                                ║"
echo "║     域名: esim.haoyiseo.com                                  ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 检查 Docker 是否安装
log_info "检查 Docker 环境..."
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装！"
    echo ""
    echo "请先安装 Docker："
    echo "  curl -fsSL https://get.docker.com | bash -"
    echo ""
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_warning "docker-compose 未安装，尝试使用 docker compose..."
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

log_success "Docker 环境检查通过"
echo ""

# 检查 .env 文件
log_info "检查配置文件..."
if [ ! -f ".env" ]; then
    log_warning ".env 文件不存在，从示例文件创建..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        log_success "已创建 .env 文件，请检查并修改配置"
    elif [ -f "env.esim.haoyiseo.com" ]; then
        cp env.esim.haoyiseo.com .env
        log_success "已从 env.esim.haoyiseo.com 创建 .env 文件"
    else
        log_error "找不到环境变量模板文件"
        exit 1
    fi
else
    log_success ".env 文件已存在"
fi
echo ""

# 创建必要的目录
log_info "创建数据目录..."
mkdir -p data logs uploads logs/nginx
log_success "数据目录创建完成"
echo ""

# 停止旧容器
log_info "停止旧容器..."
$DOCKER_COMPOSE down 2>/dev/null || true
log_success "旧容器已停止"
echo ""

# 构建镜像
log_info "构建 Docker 镜像..."
$DOCKER_COMPOSE build --no-cache
if [ $? -eq 0 ]; then
    log_success "镜像构建成功"
else
    log_error "镜像构建失败"
    exit 1
fi
echo ""

# 启动容器
log_info "启动容器..."
$DOCKER_COMPOSE up -d
if [ $? -eq 0 ]; then
    log_success "容器启动成功"
else
    log_error "容器启动失败"
    exit 1
fi
echo ""

# 等待服务启动
log_info "等待服务启动..."
sleep 5

# 检查容器状态
log_info "检查容器状态..."
echo ""
$DOCKER_COMPOSE ps
echo ""

# 健康检查
log_info "执行健康检查..."
sleep 3

if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    log_success "后端服务健康检查通过"
else
    log_warning "后端服务健康检查失败"
fi

if curl -f http://localhost/api/health > /dev/null 2>&1; then
    log_success "Nginx 代理健康检查通过"
else
    log_warning "Nginx 代理健康检查失败"
fi
echo ""

# 显示日志
log_info "最近的日志："
echo ""
$DOCKER_COMPOSE logs --tail=20
echo ""

# 完成
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ 部署完成！                                               ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
log_info "访问地址："
echo "  - HTTP:  http://esim.haoyiseo.com"
echo "  - HTTPS: https://esim.haoyiseo.com (配置 SSL 后)"
echo ""
log_info "常用命令："
echo "  查看日志:   $DOCKER_COMPOSE logs -f"
echo "  重启服务:   $DOCKER_COMPOSE restart"
echo "  停止服务:   $DOCKER_COMPOSE down"
echo "  查看状态:   $DOCKER_COMPOSE ps"
echo ""

