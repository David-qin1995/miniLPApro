# ========================================
# 生产环境配置 - esim.haoyiseo.com
# ========================================
# 部署时将此文件重命名为 .env

# 服务器配置
PORT=3000
NODE_ENV=production

# 数据库
DB_PATH=./data/db.json

# CORS (您的域名)
CORS_ORIGIN=https://esim.haoyiseo.com

# 文件上传
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760

# Session 密钥（请修改为随机字符串）
SESSION_SECRET=change-this-to-random-string-esim-haoyiseo

# ========================================
# LPAC 配置（可选）
# ========================================

# 是否使用模拟数据
# true  = 模拟模式（不需要 lpac 和硬件）
# false = 真实模式（需要安装 lpac 和 eUICC 硬件）
USE_MOCK_DATA=true

# APDU 驱动类型
APDU_DRIVER=auto

# lpac 日志级别
LPAC_LOG_LEVEL=warn

