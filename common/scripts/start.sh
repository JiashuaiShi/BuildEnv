#!/bin/bash

# ==============================================================================
#
#                         通用开发环境启动脚本
#
# 功能:
#   - 自动检测当前环境类型
#   - 启动开发环境容器
#   - 提供清晰的日志输出和用户指引
#
# ==============================================================================

# --- 脚本健壮性设置 ---
set -euo pipefail

# --- 获取当前环境信息 ---
CURRENT_DIR="$(pwd)"
ENV_TYPE=""

# 从当前路径判断环境类型
case "${CURRENT_DIR}" in
    *hpc*)
        ENV_TYPE="hpc"
        ;;
    *web*)
        ENV_TYPE="web"
        ;;
    *nas*)
        ENV_TYPE="nas"
        ;;
    *ai*)
        ENV_TYPE="ai"
        ;;
    *)
        echo "无法确定环境类型，请确保在环境目录中运行此脚本"
        exit 1
        ;;
esac

# --- ANSI 颜色代码定义 ---
COLOR_BLUE='\033[1;34m'
COLOR_GREEN='\033[1;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[1;31m'
COLOR_NC='\033[0m' # No Color

# --- 日志函数封装 ---
log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"; }
log_success() { echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $1"; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1"; exit 1; }

# --- 主逻辑开始 ---
log_info "正在启动 ${ENV_TYPE} 开发环境..."

# 1. 检查依赖: Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    log_error "未检测到 Docker。请先安装 Docker。"
fi
if ! docker compose version &> /dev/null; then
    log_error "未检测到 Docker Compose。请确保您的 Docker 版本包含 Compose。"
fi

# 2. 检查 .env 文件是否存在
ENV_FILE=".env"
if [ ! -f "${ENV_FILE}" ]; then
    log_error "配置文件 '${ENV_FILE}' 未找到。请先运行 './build.sh' 或从 '.env.example' 复制。"
fi

# 3. 环境特定预处理
if [ "${ENV_TYPE}" == "nas" ]; then
    SHARE_DIR="./share"
    log_info "正在确保共享目录 '${SHARE_DIR}' 已创建..."
    mkdir -p "${SHARE_DIR}"
fi

# 4. 使用 Docker Compose 启动容器
log_info "正在后台启动容器..."
docker compose up -d

log_success "========== 环境已启动 =========="
log_info "要查看实时日志，请运行: ./dev-cli.sh logs"
log_info "要通过 SSH 连接，请运行: ./dev-cli.sh ssh"
log_info "要停止环境，请运行:   ./dev-cli.sh stop"
