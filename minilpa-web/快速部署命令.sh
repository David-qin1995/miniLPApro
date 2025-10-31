#!/bin/bash

# ========================================
# 快速部署到 esim.haoyiseo.com
# 部署路径：/www/wwwroot/minilpa-web
# ========================================

echo "🚀 MiniLPA 快速部署脚本"
echo "域名: esim.haoyiseo.com"
echo ""

# 第一步：克隆仓库并提取 minilpa-web 目录
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 1: 克隆仓库"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "在服务器上执行："
echo ""
cat << 'COMMANDS'
cd /www/wwwroot
git clone https://github.com/David-qin1995/miniLPApro.git temp-minilpa
mv temp-minilpa/minilpa-web minilpa-web
rm -rf temp-minilpa
COMMANDS
echo ""

# 第二步：进入项目目录
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 2: 进入项目目录"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat << 'COMMANDS'
cd /www/wwwroot/minilpa-web
COMMANDS
echo ""

# 第三步：运行部署脚本
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 3: 运行部署脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat << 'COMMANDS'
bash 一键部署到esim.haoyiseo.com.sh
COMMANDS
echo ""

# 完整命令
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 或者复制以下完整命令（一次执行）："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat << 'COMMANDS'
cd /www/wwwroot && \
git clone https://github.com/David-qin1995/miniLPApro.git temp-minilpa && \
mv temp-minilpa/minilpa-web minilpa-web && \
rm -rf temp-minilpa && \
cd minilpa-web && \
bash 一键部署到esim.haoyiseo.com.sh
COMMANDS
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 重要路径说明："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "• 项目根目录:   /www/wwwroot/minilpa-web"
echo "• 前端构建目录: /www/wwwroot/minilpa-web/client/dist"
echo "• 后端入口:     /www/wwwroot/minilpa-web/server/index.js"
echo "• 数据库:       /www/wwwroot/minilpa-web/data/db.json"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 部署完成后访问："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "http://esim.haoyiseo.com"
echo "https://esim.haoyiseo.com (配置 SSL 后)"
echo ""

