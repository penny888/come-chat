#!/bin/bash

# ==================== 配置信息（固定你的仓库）====================
REMOTE_URL="git@github.com:penny888/come-chat.git"
REMOTE_BRANCH="main"
COMMIT_MSG="auto commit: project update"

# ==================== 自动执行 Git 流程 ====================
echo "===== 开始自动 Git 提交并推送 ====="

# 1. 初始化仓库（如果未初始化）
if [ ! -d .git ]; then
    git init
    echo "✅ git init 完成"
fi

# 2. 设置远程仓库
git remote set-url origin $REMOTE_URL
echo "✅ 远程仓库已配置: $REMOTE_URL"

# 3. 拉取远程代码（避免冲突）
echo "⏳ 正在拉取远程 $REMOTE_BRANCH 分支..."
git pull origin $REMOTE_BRANCH --allow-unrelated-histories

# 4. 添加所有文件
git add .
echo "✅ git add . 完成"

# 5. 提交
git commit -m "$COMMIT_MSG"
echo "✅ git commit 完成"

# 6. 推送到远程 main 分支
echo "⏳ 正在推送到远程 $REMOTE_BRANCH 分支..."
git push -u origin HEAD:$REMOTE_BRANCH

# ==================== 完成 ====================
echo ""
echo "🎉 全部完成！代码已推送到 GitHub main 分支"
echo "📦 仓库地址：$REMOTE_URL"
echo "🌿 目标分支：$REMOTE_BRANCH"

read -p "按回车退出..."