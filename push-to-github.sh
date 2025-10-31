#!/bin/bash

# ========================================
# 推送 MiniLPA 代码到 GitHub
# ========================================

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🚀 推送代码到 GitHub                                        ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 确保在正确的目录
cd /Users/jason/devTools/code/miniplapro

# 显示当前状态
echo "📊 当前状态："
echo ""
git status
echo ""

# 显示待推送的提交
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 待推送的提交："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
git log origin/main..HEAD --oneline
echo ""

# 推送
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 开始推送..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ✅ 推送成功！                                               ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🎉 代码已成功推送到 GitHub！"
    echo ""
    echo "🌐 仓库地址:"
    echo "   https://github.com/David-qin1995/miniLPApro"
    echo ""
    echo "📦 现在可以在服务器上部署了："
    echo ""
    echo "   cd /www/wwwroot && \\"
    echo "   git clone https://github.com/David-qin1995/miniLPApro.git temp-minilpa && \\"
    echo "   mv temp-minilpa/minilpa-web minilpa-web && \\"
    echo "   rm -rf temp-minilpa && \\"
    echo "   cd minilpa-web && \\"
    echo "   bash 一键部署到esim.haoyiseo.com.sh"
    echo ""
else
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ❌ 推送失败                                                 ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "💡 可能的原因："
    echo ""
    echo "1. 需要输入 GitHub 凭证"
    echo "   • Username: David-qin1995"
    echo "   • Password: 使用 Personal Access Token"
    echo ""
    echo "2. 生成 Token:"
    echo "   https://github.com/settings/tokens"
    echo ""
    echo "3. 或使用 GitHub Desktop（最简单）："
    echo "   https://desktop.github.com/"
    echo ""
fi

