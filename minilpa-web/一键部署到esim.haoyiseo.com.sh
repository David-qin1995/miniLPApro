#!/bin/bash

# ==============================================
# 一键部署到 esim.haoyiseo.com
# ==============================================

echo "🚀 开始部署 MiniLPA 到 esim.haoyiseo.com..."
echo ""

# 检查是否在服务器上
if [ ! -f "/www/server/panel/class/public.py" ]; then
    echo "❌ 错误：请在宝塔服务器上运行此脚本！"
    echo "请使用 SSH 登录服务器后执行。"
    exit 1
fi

# 检查是否在正确的目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本！"
    echo "cd /www/wwwroot/minilpa-web"
    exit 1
fi

echo "✅ 环境检查通过"
echo ""

# 1. 配置环境变量
echo "📝 配置环境变量..."
if [ ! -f ".env" ]; then
    cp env.esim.haoyiseo.com .env
    echo "✅ 已创建 .env 文件"
else
    echo "⚠️  .env 已存在，跳过"
fi
echo ""

# 2. 安装依赖
echo "📦 安装依赖..."
npm install
cd client && npm install && cd ..
echo "✅ 依赖安装完成"
echo ""

# 3. 构建前端
echo "🏗️  构建前端..."
npm run build
echo "✅ 构建完成"
echo ""

# 4. 配置 PM2
echo "⚙️  配置 PM2..."
pm2 delete minilpa 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
pm2 startup
echo "✅ PM2 配置完成"
echo ""

# 5. 配置 Nginx
echo "🌐 配置 Nginx..."
NGINX_CONF="/www/server/panel/vhost/nginx/minilpa.conf"
if [ ! -f "$NGINX_CONF" ]; then
    cp nginx-esim.haoyiseo.com.conf "$NGINX_CONF"
    nginx -t && nginx -s reload
    echo "✅ Nginx 配置完成"
else
    echo "⚠️  Nginx 配置已存在"
    echo "   如需更新，请手动复制："
    echo "   cp nginx-esim.haoyiseo.com.conf $NGINX_CONF"
    echo "   nginx -s reload"
fi
echo ""

# 6. 设置权限
echo "🔒 设置权限..."
mkdir -p data logs uploads
chown -R www:www .
chmod -R 755 .
chmod -R 775 data logs uploads
echo "✅ 权限设置完成"
echo ""

# 7. 配置防火墙
echo "🔥 配置防火墙..."
firewall-cmd --permanent --add-service=http 2>/dev/null || true
firewall-cmd --permanent --add-service=https 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true
echo "✅ 防火墙配置完成"
echo ""

# 8. 验证部署
echo "🔍 验证部署..."
sleep 3

if pm2 list | grep -q "minilpa.*online"; then
    echo "✅ PM2 进程正常运行"
else
    echo "❌ PM2 进程异常"
fi

if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ 后端服务正常"
else
    echo "❌ 后端服务异常"
fi

if nginx -t 2>/dev/null; then
    echo "✅ Nginx 配置正确"
else
    echo "❌ Nginx 配置异常"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║          🎉 部署完成！                                    ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 访问地址:"
echo "   HTTP:  http://esim.haoyiseo.com"
echo "   HTTPS: https://esim.haoyiseo.com (配置 SSL 后)"
echo ""
echo "📋 后续步骤:"
echo "   1. 确保 DNS 已解析: esim.haoyiseo.com → 服务器IP"
echo "   2. 在宝塔面板申请 SSL 证书"
echo "   3. 开启强制 HTTPS"
echo ""
echo "🔧 常用命令:"
echo "   pm2 status          - 查看进程状态"
echo "   pm2 logs minilpa    - 查看日志"
echo "   pm2 restart minilpa - 重启服务"
echo ""
