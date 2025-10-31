#!/bin/bash

# MiniLPA Web 本地开发启动脚本

echo "========================================"
echo "  MiniLPA Web - 本地开发环境"
echo "========================================"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

echo "✅ Node.js 版本: $(node -v)"
echo "✅ npm 版本: $(npm -v)"
echo ""

# 进入项目目录
cd "$(dirname "$0")"

# 检查依赖
if [ ! -d "node_modules" ]; then
    echo "📦 安装后端依赖..."
    npm install
fi

if [ ! -d "client/node_modules" ]; then
    echo "📦 安装前端依赖..."
    cd client && npm install && cd ..
fi

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo "⚙️  创建环境变量文件..."
    cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
DB_PATH=./data/db.json
CORS_ORIGIN=*
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
SESSION_SECRET=dev-secret-key-for-local-testing
EOF
fi

# 创建必要的目录
mkdir -p data uploads logs

echo ""
echo "🚀 启动开发服务器..."
echo ""
echo "后端服务: http://localhost:3000"
echo "前端服务: http://localhost:5173"
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

# 使用 trap 捕获退出信号，确保子进程被清理
trap 'kill $(jobs -p) 2>/dev/null' EXIT

# 启动后端服务器
node server/index.js &
BACKEND_PID=$!

# 等待后端启动
sleep 2

# 启动前端服务器
cd client
npm run dev &
FRONTEND_PID=$!

# 等待两个进程
wait $BACKEND_PID $FRONTEND_PID

