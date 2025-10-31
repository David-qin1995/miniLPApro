#!/bin/bash
###############################################################################
# MiniLPA Web - 宝塔部署命令清单
# 部署路径: /www/wwwroot/minilpa
# 
# 使用方法：
# 1. 复制需要的命令到终端执行
# 2. 或者直接运行: bash 部署命令清单.sh
###############################################################################

echo "═══════════════════════════════════════════════════════════"
echo "  MiniLPA Web - 宝塔部署命令清单"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ============================================================
# 步骤 1: 上传项目到服务器
# ============================================================
echo "【步骤 1】上传项目到服务器"
echo ""
echo "# 方式 A: 使用 Git（推荐）"
echo "cd /www/wwwroot"
echo "git clone <your-repository-url> minilpa"
echo ""
echo "# 方式 B: 手动上传"
echo "# 1. 在本地打包: tar -czf minilpa-web.tar.gz ."
echo "# 2. 使用宝塔面板上传到 /www/wwwroot/minilpa"
echo "# 3. 解压: cd /www/wwwroot/minilpa && tar -xzf minilpa-web.tar.gz"
echo ""
echo "按回车继续..."
read

# ============================================================
# 步骤 2: 一键部署
# ============================================================
echo "【步骤 2】一键部署"
echo ""
echo "cd /www/wwwroot/minilpa"
echo "bash scripts/baota-deploy.sh"
echo ""
echo "执行上述命令即可完成部署！"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  或者，手动执行以下命令："
echo "═══════════════════════════════════════════════════════════"
echo ""

# ============================================================
# 手动部署命令
# ============================================================

echo "# 1. 进入项目目录"
echo "cd /www/wwwroot/minilpa"
echo ""

echo "# 2. 安装依赖"
echo "npm install --production"
echo "cd client && npm install && cd .."
echo ""

echo "# 3. 创建环境变量文件"
cat << 'ENVEOF'
cat > .env << 'EOF'
PORT=3000
NODE_ENV=production
DB_PATH=./data/db.json
CORS_ORIGIN=https://yourdomain.com
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
SESSION_SECRET=$(openssl rand -hex 32)
USE_MOCK_DATA=true
APDU_DRIVER=auto
LPAC_LOG_LEVEL=warn
EOF
ENVEOF
echo ""

echo "# 4. 构建前端"
echo "npm run build"
echo ""

echo "# 5. 设置权限"
echo "mkdir -p data uploads logs"
echo "chown -R www:www /www/wwwroot/minilpa"
echo "chmod -R 755 /www/wwwroot/minilpa"
echo ""

echo "# 6. 启动 PM2"
echo "pm2 start ecosystem.config.js --env production"
echo "pm2 save"
echo "pm2 startup"
echo ""

echo "# 7. 配置 Nginx（在宝塔面板中操作）"
echo "# - 添加站点，根目录指向: /www/wwwroot/minilpa/client/dist"
echo "# - 配置反向代理: /api -> http://127.0.0.1:3000"
echo ""

echo "# 8. 验证部署"
echo "pm2 status"
echo "curl http://localhost:3000/api/health"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "  常用管理命令："
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "# 查看状态"
echo "pm2 status"
echo ""

echo "# 查看日志"
echo "pm2 logs minilpa"
echo "tail -f /www/wwwroot/minilpa/logs/nginx-access.log"
echo ""

echo "# 重启服务"
echo "pm2 restart minilpa"
echo "nginx -s reload"
echo ""

echo "# 更新应用"
echo "cd /www/wwwroot/minilpa"
echo "git pull"
echo "npm install && cd client && npm install && cd .."
echo "npm run build"
echo "pm2 restart minilpa"
echo ""

echo "# 备份数据"
echo "tar -czf ~/minilpa-backup-\$(date +%Y%m%d).tar.gz /www/wwwroot/minilpa/data /www/wwwroot/minilpa/uploads"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "  部署完成！"
echo "═══════════════════════════════════════════════════════════"

