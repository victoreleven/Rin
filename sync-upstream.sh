#!/bin/bash

# Rin 博客 - 同步上游更新脚本
# 使用方法: ./sync-upstream.sh

set -e

echo "========================================="
echo "  同步 Rin 上游仓库更新"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}❌ 你有未提交的更改！${NC}"
    echo "请先提交或暂存你的更改："
    echo "  git add ."
    echo "  git commit -m '你的更改'"
    echo ""
    exit 1
fi

# 获取上游更新
echo "📥 正在获取上游更新..."
git fetch upstream

# 检查是否有新的提交
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse upstream/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo -e "${GREEN}✅ 已经是最新版本，无需同步${NC}"
    exit 0
fi

echo -e "${YELLOW}⚠️  发现新的更新，准备合并...${NC}"
echo ""

# 显示上游的更新日志
echo "📋 上游最近的提交："
git log HEAD..upstream/main --oneline | head -5
echo ""

# 询问是否继续
read -p "是否继续合并？(y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消同步"
    exit 0
fi

# 合并上游更新
echo ""
echo "🔄 正在合并上游更新..."
git merge upstream/main -m "merge: sync with upstream $(date +%Y-%m-%d)"

# 检查是否有冲突
if [ -n "$(git ls-files -u)" ]; then
    echo ""
    echo -e "${RED}⚠️  检测到合并冲突！${NC}"
    echo ""
    echo "冲突文件："
    git diff --name-only --diff-filter=U
    echo ""
    echo "请手动解决冲突："
    echo "  1. 编辑标记为冲突的文件"
    echo "  2. 解决冲突后运行: git add <文件>"
    echo "  3. 完成后运行: git commit"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ 同步成功！${NC}"
    echo ""
    echo "现在可以推送到你的仓库："
    echo "  git push origin main"
    echo ""
fi
