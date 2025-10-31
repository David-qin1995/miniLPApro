#!/bin/bash

# MiniLPA Web 部署脚本
# 使用方法: bash deploy.sh

set -e

echo "========================================="
echo "  MiniLPA Web 部署脚本"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目目录
PROJECT_DIR="/www/wwwroot/minilpa-web"
APP_NAME="minilpa-web"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}请使用 root 用户或 sudo 运行此脚本${NC}"
    exit 1
fi

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}项目目录不存在: $PROJECT_DIR${NC}"
    exit 1
fi

cd $PROJECT_DIR

echo -e "${GREEN}[1/8]${NC} 拉取最新代码..."
git pull origin main || {
    echo -e "${YELLOW}Git 拉取失败或无 Git 仓库，跳过此步骤${NC}"
}

echo -e "${GREEN}[2/8]${NC} 安装后端依赖..."
npm install --production

echo -e "${GREEN}[3/8]${NC} 安装前端依赖..."
cd client
npm install
cd ..

echo -e "${GREEN}[4/8]${NC} 构建前端..."
npm run build

echo -e "${GREEN}[5/8]${NC} 设置目录权限..."
chown -R www:www $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

# 确保必要的目录存在
mkdir -p $PROJECT_DIR/data
mkdir -p $PROJECT_DIR/uploads
mkdir -p $PROJECT_DIR/logs

chown -R www:www $PROJECT_DIR/data
chown -R www:www $PROJECT_DIR/uploads
chown -R www:www $PROJECT_DIR/logs

echo -e "${GREEN}[6/8]${NC} 检查 PM2..."
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}PM2 未安装，正在安装...${NC}"
    npm install -g pm2
fi

echo -e "${GREEN}[7/8]${NC} 重启应用..."
if pm2 describe $APP_NAME > /dev/null 2>&1; then
    pm2 reload $APP_NAME
    echo -e "${GREEN}应用已重载${NC}"
else
    pm2 start ecosystem.config.js
    pm2 save
    echo -e "${GREEN}应用已启动${NC}"
fi

echo -e "${GREEN}[8/8]${NC} 重载 Nginx..."
nginx -t && nginx -s reload || {
    echo -e "${YELLOW}Nginx 重载失败，请手动检查配置${NC}"
}

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "应用状态:"
pm2 status $APP_NAME
echo ""
echo "查看日志: pm2 logs $APP_NAME"
echo "重启应用: pm2 restart $APP_NAME"
echo "停止应用: pm2 stop $APP_NAME"
echo ""

