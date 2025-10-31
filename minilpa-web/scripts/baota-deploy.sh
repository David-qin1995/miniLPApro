#!/bin/bash

###############################################################################
# MiniLPA Web - 宝塔面板 CentOS 7 一键部署脚本
# 部署路径: /www/wwwroot/minilpa
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
PROJECT_DIR="/www/wwwroot/minilpa-web"
APP_NAME="minilpa"
DOMAIN="esim.haoyiseo.com"  # 您的域名

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

# 打印标题
print_header() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}║        MiniLPA Web - 宝塔部署脚本                    ║${NC}"
    echo -e "${GREEN}║        部署路径: /www/wwwroot/minilpa                ║${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "请使用 root 用户运行此脚本"
        exit 1
    fi
    log_success "Root 权限检查通过"
}

# 检查项目目录
check_project_dir() {
    log_info "检查项目目录..."
    if [ ! -d "$PROJECT_DIR" ]; then
        log_error "项目目录不存在: $PROJECT_DIR"
        log_info "请先将项目上传到 $PROJECT_DIR"
        exit 1
    fi
    cd "$PROJECT_DIR"
    log_success "项目目录检查通过"
}

# 检查必要的软件
check_dependencies() {
    log_info "检查依赖软件..."
    
    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装，请在宝塔面板安装 Node.js"
        exit 1
    fi
    log_success "Node.js $(node -v) 已安装"
    
    # 检查 npm
    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装"
        exit 1
    fi
    log_success "npm $(npm -v) 已安装"
    
    # 检查 PM2
    if ! command -v pm2 &> /dev/null; then
        log_warning "PM2 未安装，正在安装..."
        npm install -g pm2
    fi
    log_success "PM2 已安装"
    
    # 检查 Nginx
    if ! command -v nginx &> /dev/null; then
        log_error "Nginx 未安装，请在宝塔面板安装 Nginx"
        exit 1
    fi
    log_success "Nginx 已安装"
}

# 安装依赖
install_dependencies() {
    log_info "[1/8] 安装依赖..."
    
    # 安装后端依赖
    log_info "安装后端依赖..."
    npm install --production
    
    # 安装前端依赖
    log_info "安装前端依赖..."
    cd client
    npm install
    cd ..
    
    log_success "依赖安装完成"
}

# 配置环境变量
configure_env() {
    log_info "[2/8] 配置环境变量..."
    
    if [ -f ".env" ]; then
        log_warning ".env 文件已存在，备份为 .env.backup"
        cp .env .env.backup
    fi
    
    # 生成随机 SECRET
    SESSION_SECRET=$(openssl rand -hex 32)
    
    cat > .env << EOF
# ========================================
# 生产环境配置
# ========================================

# 服务器配置
PORT=3000
NODE_ENV=production

# 数据库
DB_PATH=./data/db.json

# CORS (修改为您的域名)
CORS_ORIGIN=https://${DOMAIN}

# 文件上传
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760

# Session 密钥
SESSION_SECRET=${SESSION_SECRET}

# ========================================
# LPAC 配置（可选）
# ========================================

# 是否使用模拟数据
USE_MOCK_DATA=true

# APDU 驱动类型
APDU_DRIVER=auto

# lpac 日志级别
LPAC_LOG_LEVEL=warn
EOF
    
    log_success "环境变量配置完成"
    log_warning "请修改 .env 文件中的域名: $DOMAIN"
}

# 构建前端
build_frontend() {
    log_info "[3/8] 构建前端..."
    npm run build
    log_success "前端构建完成"
}

# 设置目录权限
setup_permissions() {
    log_info "[4/8] 设置目录权限..."
    
    # 创建必要的目录
    mkdir -p data uploads logs
    
    # 设置权限
    chown -R www:www "$PROJECT_DIR"
    chmod -R 755 "$PROJECT_DIR"
    
    log_success "目录权限设置完成"
}

# 配置 PM2
setup_pm2() {
    log_info "[5/8] 配置 PM2..."
    
    # 停止旧的进程（如果存在）
    pm2 delete "$APP_NAME" 2>/dev/null || true
    
    # 启动应用
    pm2 start ecosystem.config.js --env production
    
    # 保存 PM2 配置
    pm2 save
    
    # 设置开机自启
    pm2 startup systemd -u root --hp /root 2>/dev/null || true
    
    log_success "PM2 配置完成"
}

# 配置 Nginx
setup_nginx() {
    log_info "[6/8] 配置 Nginx..."
    
    NGINX_CONF="/www/server/panel/vhost/nginx/${APP_NAME}.conf"
    
    # 备份现有配置
    if [ -f "$NGINX_CONF" ]; then
        log_warning "Nginx 配置已存在，备份为 ${APP_NAME}.conf.backup"
        cp "$NGINX_CONF" "${NGINX_CONF}.backup"
    fi
    
    # 创建 Nginx 配置
    cat > "$NGINX_CONF" << 'EOF'
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    
    # 日志
    access_log /www/wwwroot/minilpa/logs/nginx-access.log;
    error_log /www/wwwroot/minilpa/logs/nginx-error.log;
    
    # 最大上传大小
    client_max_body_size 10M;
    
    # 前端静态文件
    location / {
        root /www/wwwroot/minilpa/client/dist;
        try_files $uri $uri/ /index.html;
        index index.html;
    }
    
    # API 反向代理
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # 超时设置
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # 上传文件访问
    location /uploads {
        proxy_pass http://127.0.0.1:3000;
    }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
    
    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF
    
    # 替换域名
    sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" "$NGINX_CONF"
    
    # 测试 Nginx 配置
    nginx -t
    
    # 重载 Nginx
    nginx -s reload
    
    log_success "Nginx 配置完成"
}

# 配置防火墙
setup_firewall() {
    log_info "[7/8] 配置防火墙..."
    
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=80/tcp 2>/dev/null || true
        firewall-cmd --permanent --add-port=443/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        log_success "防火墙配置完成"
    else
        log_warning "firewalld 未运行，请手动配置防火墙"
    fi
}

# 验证部署
verify_deployment() {
    log_info "[8/8] 验证部署..."
    
    # 等待服务启动
    sleep 3
    
    # 检查 PM2
    if pm2 list | grep -q "$APP_NAME"; then
        log_success "PM2 进程运行正常"
    else
        log_error "PM2 进程未运行"
        exit 1
    fi
    
    # 检查后端
    if curl -s http://localhost:3000/api/health | grep -q "ok"; then
        log_success "后端 API 响应正常"
    else
        log_warning "后端 API 可能未正常启动"
    fi
    
    # 检查前端文件
    if [ -f "client/dist/index.html" ]; then
        log_success "前端文件存在"
    else
        log_error "前端文件不存在"
        exit 1
    fi
}

# 打印部署信息
print_summary() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}║              部署完成！                               ║${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}部署信息:${NC}"
    echo -e "  • 项目路径: ${GREEN}${PROJECT_DIR}${NC}"
    echo -e "  • 应用名称: ${GREEN}${APP_NAME}${NC}"
    echo -e "  • 后端端口: ${GREEN}3000${NC}"
    echo -e "  • 访问地址: ${GREEN}http://${DOMAIN}${NC}"
    echo ""
    echo -e "${BLUE}常用命令:${NC}"
    echo -e "  • 查看状态: ${YELLOW}pm2 status${NC}"
    echo -e "  • 查看日志: ${YELLOW}pm2 logs ${APP_NAME}${NC}"
    echo -e "  • 重启服务: ${YELLOW}pm2 restart ${APP_NAME}${NC}"
    echo -e "  • 停止服务: ${YELLOW}pm2 stop ${APP_NAME}${NC}"
    echo ""
    echo -e "${BLUE}下一步:${NC}"
    echo -e "  1. 修改域名: ${YELLOW}vim ${PROJECT_DIR}/.env${NC}"
    echo -e "  2. 配置 SSL: 在宝塔面板中申请 SSL 证书"
    echo -e "  3. 访问应用: ${GREEN}http://${DOMAIN}${NC}"
    echo ""
    echo -e "${YELLOW}注意: 请修改 .env 和 Nginx 配置中的域名！${NC}"
    echo ""
}

# 主函数
main() {
    print_header
    check_root
    check_project_dir
    check_dependencies
    install_dependencies
    configure_env
    build_frontend
    setup_permissions
    setup_pm2
    setup_nginx
    setup_firewall
    verify_deployment
    print_summary
}

# 执行主函数
main "$@"

