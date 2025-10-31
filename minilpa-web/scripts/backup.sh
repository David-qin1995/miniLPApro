#!/bin/bash

# MiniLPA Web 备份脚本
# 使用方法: bash backup.sh

set -e

echo "========================================="
echo "  MiniLPA Web 备份脚本"
echo "========================================="
echo ""

# 项目目录
PROJECT_DIR="/www/wwwroot/minilpa-web"
BACKUP_DIR="/www/backup/minilpa-web"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="minilpa-web-backup-$DATE.tar.gz"

# 创建备份目录
mkdir -p $BACKUP_DIR

echo "[1/3] 创建备份..."
cd $PROJECT_DIR

# 备份数据库和上传文件
tar -czf $BACKUP_DIR/$BACKUP_FILE \
    --exclude='node_modules' \
    --exclude='client/node_modules' \
    --exclude='client/dist' \
    --exclude='.git' \
    data/ uploads/ .env 2>/dev/null || true

echo "[2/3] 备份完成: $BACKUP_DIR/$BACKUP_FILE"

# 删除30天前的备份
echo "[3/3] 清理旧备份..."
find $BACKUP_DIR -name "minilpa-web-backup-*.tar.gz" -mtime +30 -delete

echo ""
echo "备份完成！"
echo "备份文件: $BACKUP_DIR/$BACKUP_FILE"
echo "备份大小: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1)"
echo ""

