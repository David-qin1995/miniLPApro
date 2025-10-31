#!/bin/bash

# ========================================
# 推送 MiniLPA 代码到 GitHub (使用 SSH)
# ========================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🚀 推送代码到 GitHub (SSH)                                  ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 确保在正确的目录
cd /Users/jason/devTools/code/miniplapro || { echo -e "${RED}❌ 目录不存在${NC}"; exit 1; }

# 检查远程配置
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo -e "${RED}❌ 未配置远程仓库${NC}"
    exit 1
fi

# 如果不是 SSH，切换到 SSH
if [[ ! "$REMOTE_URL" =~ ^git@ ]]; then
    echo -e "${YELLOW}⚠️  当前使用 HTTPS，切换到 SSH...${NC}"
    git remote set-url origin git@github.com:David-qin1995/miniLPApro.git
    echo -e "${GREEN}✅ 已切换到 SSH${NC}"
    echo ""
fi

# 显示当前状态
echo -e "${BLUE}📊 当前状态：${NC}"
echo ""
git status --short
echo ""

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  有未提交的更改${NC}"
    git status --short
    echo ""
fi

# 显示待推送的提交
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 待推送的提交：${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PENDING_COMMITS=$(git log origin/main..HEAD --oneline 2>/dev/null || git log --oneline -5)

if [ -z "$PENDING_COMMITS" ]; then
    echo -e "${YELLOW}⚠️  没有待推送的提交${NC}"
    echo ""
    echo "当前最新提交："
    git log --oneline -1
    echo ""
    read -p "是否强制推送？(y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    echo "$PENDING_COMMITS"
fi

echo ""

# 测试 SSH 连接
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔐 测试 SSH 连接...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

SSH_TEST=$(ssh -T git@github.com 2>&1)
if echo "$SSH_TEST" | grep -q "successfully authenticated"; then
    echo -e "${GREEN}✅ SSH 连接测试成功${NC}"
elif echo "$SSH_TEST" | grep -q "Permission denied"; then
    echo -e "${RED}❌ SSH 权限被拒绝${NC}"
    echo ""
    echo -e "${YELLOW}💡 解决方案：${NC}"
    echo ""
    echo "1. 检查 SSH 密钥是否添加到 GitHub："
    echo "   • 访问: https://github.com/settings/keys"
    echo "   • 确保密钥不是 Deploy Key（只读）"
    echo "   • 如果是 Deploy Key，删除后添加为个人 SSH Key"
    echo ""
    echo "2. 显示您的公钥（复制并添加到 GitHub）："
    echo ""
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        echo "   cat ~/.ssh/id_ed25519.pub"
        echo ""
        echo "   公钥内容："
        cat ~/.ssh/id_ed25519.pub
        echo ""
    elif [ -f ~/.ssh/id_rsa.pub ]; then
        echo "   cat ~/.ssh/id_rsa.pub"
        echo ""
        echo "   公钥内容："
        cat ~/.ssh/id_rsa.pub
        echo ""
    fi
    echo ""
    echo "3. 添加密钥后，按任意键继续推送..."
    read -n 1 -r
    echo ""
else
    echo -e "${YELLOW}⚠️  SSH 连接测试结果：${NC}"
    echo "$SSH_TEST"
    echo ""
fi

# 推送
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 开始推送...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if git push origin main; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ✅ 推送成功！                                               ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}🎉 代码已成功推送到 GitHub！${NC}"
    echo ""
    echo -e "${BLUE}🌐 仓库地址:${NC}"
    echo "   https://github.com/David-qin1995/miniLPApro"
    echo ""
    echo -e "${BLUE}📦 现在可以在服务器上部署了：${NC}"
    echo ""
    echo "   # Docker 镜像部署（推荐）"
    echo "   cd /www/wwwroot/minilpa-web"
    echo "   bash docker-pull-deploy.sh"
    echo ""
    echo "   # 或传统部署"
    echo "   bash 一键部署到esim.haoyiseo.com.sh"
    echo ""
    exit 0
else
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ❌ 推送失败                                                 ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${RED}💡 可能的原因：${NC}"
    echo ""
    echo "1. SSH 密钥权限不足"
    echo "   • 访问: https://github.com/settings/keys"
    echo "   • 检查是否有 Deploy Key（只读）"
    echo "   • 删除后添加为个人 SSH Key（可读写）"
    echo ""
    echo "2. 仓库需要先拉取最新代码"
    echo "   git pull origin main --rebase"
    echo "   git push origin main"
    echo ""
    echo "3. 使用 HTTPS 方式（备选）"
    echo "   git remote set-url origin https://github.com/David-qin1995/miniLPApro.git"
    echo "   git push origin main"
    echo ""
    exit 1
fi
