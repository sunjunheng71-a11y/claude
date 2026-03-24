#!/bin/bash

# GitHub自动化脚本
# Claude Code全自动GitHub集成工具

set -e

echo "🐙 GitHub自动化工具"
echo "========================"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/.claude/github-config.json"

# 加载GitHub配置
load_github_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # 尝试使用jq（如果可用）
        if command -v jq >/dev/null 2>&1; then
            GITHUB_REPO=$(jq -r '.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
            GITHUB_BRANCH=$(jq -r '.branch' "$CONFIG_FILE" 2>/dev/null || echo "main")
            GITHUB_TOKEN=$(jq -r '.token' "$CONFIG_FILE" 2>/dev/null || echo "")
        else
            # 备用方法：使用grep和sed提取JSON值
            GITHUB_REPO=$(grep -o '"repository":[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/"repository":[[:space:]]*"\([^"]*\)"/\1/' || echo "")
            GITHUB_BRANCH=$(grep -o '"branch":[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/"branch":[[:space:]]*"\([^"]*\)"/\1/' || echo "main")
            GITHUB_TOKEN=$(grep -o '"token":[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/"token":[[:space:]]*"\([^"]*\)"/\1/' || echo "")
        fi
    else
        GITHUB_REPO=""
        GITHUB_BRANCH="main"
        GITHUB_TOKEN=""
    fi

    # 如果从配置文件读取失败，使用默认值
    GITHUB_REPO=${GITHUB_REPO:-""}
    GITHUB_BRANCH=${GITHUB_BRANCH:-"main"}
    GITHUB_TOKEN=${GITHUB_TOKEN:-""}
}

# 保存GitHub配置
save_github_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
{
  "repository": "${GITHUB_REPO}",
  "branch": "${GITHUB_BRANCH}",
  "token": "${GITHUB_TOKEN}",
  "last_updated": "$(date '+%Y-%m-%d %H:%M:%S')",
  "auto_sync": true
}
EOF
    echo "✅ GitHub配置已保存"
}

# 配置GitHub仓库
configure_repo() {
    echo "🔧 配置GitHub仓库"
    echo "----------------"

    read -p "GitHub仓库URL (例如: https://github.com/username/repo): " repo_url
    if [ -z "$repo_url" ]; then
        echo "❌ 仓库URL不能为空"
        return 1
    fi

    # 提取仓库路径
    if [[ $repo_url == https://github.com/* ]]; then
        GITHUB_REPO=$repo_url
    else
        echo "❌ 无效的GitHub URL格式"
        return 1
    fi

    read -p "分支名称 (默认: main): " branch
    GITHUB_BRANCH=${branch:-main}

    read -p "GitHub个人访问令牌 (可选，用于私有仓库): " token
    GITHUB_TOKEN=$token

    save_github_config
    echo ""
    echo "📋 配置摘要:"
    echo "  仓库: $GITHUB_REPO"
    echo "  分支: $GITHUB_BRANCH"
    echo "  令牌: ${GITHUB_TOKEN:-未设置}"
}

# 克隆仓库
clone_repo() {
    load_github_config

    if [ -z "$GITHUB_REPO" ]; then
        echo "❌ 未配置GitHub仓库"
        echo "💡 请先运行: bash $0 configure"
        return 1
    fi

    echo "📥 克隆仓库: $GITHUB_REPO"
    echo "分支: $GITHUB_BRANCH"

    # 检查是否已存在
    if [ -d "$ROOT_DIR/.git" ]; then
        echo "⚠️  当前目录已是Git仓库"
        read -p "是否重新克隆？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
        rm -rf "$ROOT_DIR/.git"
    fi

    # 克隆命令
    if [ -n "$GITHUB_TOKEN" ]; then
        # 使用token认证
        repo_with_token="${GITHUB_REPO/https:\/\//https://${GITHUB_TOKEN}@}"
        git clone -b "$GITHUB_BRANCH" "$repo_with_token" "$ROOT_DIR" --depth 1
    else
        git clone -b "$GITHUB_BRANCH" "$GITHUB_REPO" "$ROOT_DIR" --depth 1
    fi

    if [ $? -eq 0 ]; then
        echo "✅ 仓库克隆成功"

        # 更新配置中的仓库信息
        save_github_config
    else
        echo "❌ 克隆失败"
        return 1
    fi
}

# 拉取最新代码
pull_updates() {
    load_github_config

    if [ ! -d "$ROOT_DIR/.git" ]; then
        echo "❌ 当前目录不是Git仓库"
        return 1
    fi

    echo "📥 拉取最新代码..."

    # 保存当前更改（如果有）
    if git status --porcelain | grep -q '.'; then
        echo "⚠️  检测到未提交的更改"
        git stash
        STASHED=true
    else
        STASHED=false
    fi

    # 拉取更新
    git pull origin "$GITHUB_BRANCH"

    if [ "$STASHED" = true ]; then
        echo "🔄 恢复未提交的更改..."
        git stash pop
    fi

    echo "✅ 代码更新完成"
}

# 推送更改
push_changes() {
    load_github_config

    if [ ! -d "$ROOT_DIR/.git" ]; then
        echo "❌ 当前目录不是Git仓库"
        return 1
    fi

    echo "📤 推送更改到GitHub..."

    # 检查是否有更改
    if ! git status --porcelain | grep -q '.'; then
        echo "ℹ️  没有需要推送的更改"
        return 0
    fi

    # 添加所有文件
    git add .

    # 提交
    commit_message="Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
    if [ $# -gt 0 ]; then
        commit_message="$*"
    fi

    git commit -m "$commit_message"

    # 推送
    if [ -n "$GITHUB_TOKEN" ]; then
        # 配置remote URL包含token
        current_remote=$(git remote get-url origin)
        if [[ $current_remote != *"${GITHUB_TOKEN}"* ]]; then
            repo_with_token="${GITHUB_REPO/https:\/\//https://${GITHUB_TOKEN}@}"
            git remote set-url origin "$repo_with_token"
        fi
    fi

    git push origin "$GITHUB_BRANCH"

    echo "✅ 更改已推送到GitHub"
}

# 同步仓库（拉取+推送）
sync_repo() {
    echo "🔄 同步GitHub仓库..."

    # 先拉取
    if pull_updates; then
        # 如果有本地更改，推送
        if git status --porcelain | grep -q '.'; then
            push_changes "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
        fi
    fi

    echo "✅ 同步完成"
}

# 显示仓库状态
show_status() {
    load_github_config

    echo "📊 GitHub仓库状态"
    echo "========================"

    if [ -z "$GITHUB_REPO" ]; then
        echo "❌ 未配置GitHub仓库"
        return 1
    fi

    echo "🔗 仓库: $GITHUB_REPO"
    echo "🌿 分支: $GITHUB_BRANCH"
    echo "🔑 令牌: ${GITHUB_TOKEN:+已设置}${GITHUB_TOKEN:-未设置}"

    if [ -d "$ROOT_DIR/.git" ]; then
        echo ""
        echo "📁 Git状态:"
        git remote -v
        echo ""

        # 显示提交历史
        echo "📝 最近提交:"
        git log --oneline -5
        echo ""

        # 显示未提交的更改
        if git status --porcelain | grep -q '.'; then
            echo "📋 未提交的更改:"
            git status --short
        else
            echo "📋 工作区干净"
        fi
    else
        echo ""
        echo "📁 当前目录不是Git仓库"
    fi

    echo ""
    echo "🕐 最后更新: $(date '+%Y-%m-%d %H:%M:%S')"
}

# 自动同步（用于cron job）
auto_sync() {
    load_github_config

    if [ -z "$GITHUB_REPO" ] || [ ! -d "$ROOT_DIR/.git" ]; then
        return 0
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 自动同步GitHub仓库"
    sync_repo > "$ROOT_DIR/logs/github-sync.log" 2>&1
}

# 主菜单
main_menu() {
    echo ""
    echo "请选择操作:"
    echo "1) 配置GitHub仓库"
    echo "2) 克隆仓库"
    echo "3) 拉取最新代码"
    echo "4) 推送更改"
    echo "5) 同步仓库（拉取+推送）"
    echo "6) 显示仓库状态"
    echo "7) 设置自动同步"
    echo "8) 退出"
    echo ""

    read -p "选择 (1-8): " choice

    case $choice in
        1) configure_repo ;;
        2) clone_repo ;;
        3) pull_updates ;;
        4) push_changes ;;
        5) sync_repo ;;
        6) show_status ;;
        7) setup_auto_sync ;;
        8) exit 0 ;;
        *) echo "❌ 无效选择" ;;
    esac

    main_menu
}

# 设置自动同步
setup_auto_sync() {
    echo "⏰ 设置自动同步"
    echo "----------------"

    echo "自动同步将在后台定期运行，保持本地与GitHub同步"
    echo ""
    echo "当前cron配置:"
    crontab -l 2>/dev/null | grep -i github || echo "未设置"

    echo ""
    read -p "设置自动同步间隔（分钟）(默认: 30): " interval
    interval=${interval:-30}

    # 创建自动同步脚本
    SYNC_SCRIPT="$ROOT_DIR/scripts/github-auto-sync.sh"
    cat > "$SYNC_SCRIPT" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/.."
bash scripts/github.sh auto-sync
EOF
    chmod +x "$SYNC_SCRIPT"

    # 添加到cron（需要用户手动操作）
    echo ""
    echo "📋 请手动添加到cron:"
    echo "crontab -e"
    echo "然后添加以下行:"
    echo "*/$interval * * * * bash \"$SYNC_SCRIPT\""
    echo ""
    echo "💡 或者使用Claude Code的定时任务功能"
}

# 命令行参数处理
case "${1:-}" in
    "configure")
        configure_repo
        ;;
    "clone")
        clone_repo
        ;;
    "pull")
        pull_updates
        ;;
    "push")
        shift
        push_changes "$@"
        ;;
    "sync")
        sync_repo
        ;;
    "status")
        show_status
        ;;
    "auto-sync")
        auto_sync
        ;;
    "auto-setup")
        setup_auto_sync
        ;;
    "")
        main_menu
        ;;
    *)
        echo "用法: $0 [configure|clone|pull|push|sync|status|auto-sync|auto-setup]"
        echo ""
        echo "示例:"
        echo "  $0 configure    # 配置GitHub仓库"
        echo "  $0 clone        # 克隆仓库"
        echo "  $0 pull         # 拉取最新代码"
        echo "  $0 push         # 推送更改"
        echo "  $0 sync         # 同步仓库"
        echo "  $0 status       # 显示仓库状态"
        echo "  $0 auto-sync    # 自动同步（后台任务）"
        exit 1
        ;;
esac

exit 0