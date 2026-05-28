#!/bin/bash

# ==================== 配置信息 ====================
REMOTE_URL="git@github.com:penny888/come-chat.git"
REMOTE_BRANCH="main"
COMMIT_MSG="auto commit: project update"

# ==================== 自动执行 ====================
echo "===== 开始自动 Git 提交并推送 ====="

# 1. 初始化仓库
if [ ! -d .git ]; then
    git init
    COMMIT_MSG="Initial commit: project setup"
    echo "✅ git init 完成"
fi

# 2. 先检查 origin 是否存在，不存在则添加
if ! git remote | grep -q "origin"; then
    git remote add origin $REMOTE_URL
    echo "✅ 已添加远程 origin"
else
    git remote set-url origin $REMOTE_URL
    echo "✅ 已更新远程 origin 地址"
fi

# 3. 尝试拉取（避免冲突）
echo "⏳ 正在拉取远程 $REMOTE_BRANCH..."
git pull origin $REMOTE_BRANCH --allow-unrelated-histories --no-rebase 2>/dev/null

# 4. 添加文件
git add .
echo "✅ git add . 完成"

# 5. 提交（如果有可提交内容）
git commit -m "$COMMIT_MSG" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ git commit 完成"
else
    echo "ℹ️ 没有需要提交的内容"
fi

# 6. 推送到远程 main（关键修复）
echo "⏳ 正在推送到远程 $REMOTE_BRANCH..."
git push -u origin HEAD:$REMOTE_BRANCH

# ==================== 完成 ====================
echo ""
echo "🎉 全部完成！代码已推送到 GitHub main 分支"
echo "📦 仓库地址：$REMOTE_URL"
echo "🌿 分支：$REMOTE_BRANCH"

read -p "按回车退出..."