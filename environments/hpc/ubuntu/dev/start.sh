#!/bin/bash

# ==============================================================================
#
#                           Ubuntu HPC 环境启动脚本
#
# 功能:
#   - 检查依赖项并加载配置。
#   - 使用 Docker Compose 在后台启动容器。
#   - 提供清晰的日志输出和用户指引。
#
# ==============================================================================

# --- 脚本健壮性设置 ---
set -euo pipefail

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

# --- 配置区 ---
ENV_FILE=".env"

# --- 主逻辑开始 ---
log_info "正在启动 Ubuntu HPC 开发环境..."

# 1. 检查依赖: Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    log_error "未检测到 Docker。请先安装 Docker。"
fi
if ! docker compose version &> /dev/null; then
    log_error "未检测到 Docker Compose。请确保您的 Docker 版本包含 Compose。"
fi

# 2. 检查 .env 文件是否存在
if [ ! -f "${ENV_FILE}" ]; then
    log_error "配置文件 '${ENV_FILE}' 未找到。请先运行 './build.sh' 或从 '.env.example' 复制。"
fi

# 3. 使用 Docker Compose 启动容器
log_info "正在后台启动容器..."
docker compose up -d

log_success "========== 环境已启动 =========="
log_info "要查看实时日志，请运行: ./dev-cli.sh logs"
log_info "要通过 SSH 连接，请运行: ./dev-cli.sh ssh"
log_info "要停止环境，请运行:   ./dev-cli.sh stop"
