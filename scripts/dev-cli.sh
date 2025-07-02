#!/bin/bash

# ==============================================================================
#
#                     通用开发环境管理命令行工具
#
# 功能:
#   - 自动检测当前环境类型
#   - 提供统一的接口管理 Docker Compose 环境
#   - 支持通过 SSH 或 exec 命令与容器交互
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
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1"; exit 1; }

# --- 配置区 ---
ENV_FILE=".env"

# --- 动态加载配置 ---
if [ -f "${ENV_FILE}" ]; then
    source "${ENV_FILE}"
fi
# 设置默认值以防 .env 文件中未定义
# 优先从 .env 文件中读取配置，如果未定义，则使用以下默认值
DEV_USER=${DEV_USER:-shijiashuai}
SSH_PORT=${SSH_PORT:-2222}

# 从当前目录名动态获取容器/服务名，确保与 docker-compose.yaml 中的服务名一致
CONTAINER_NAME=$(basename "$(pwd)")

# --- 用法说明 ---
usage() {
    echo -e "${COLOR_BLUE}用法: $0 {start|stop|restart|down|logs|ssh|exec}${COLOR_NC}"
    echo "  start    - 在后台启动容器"
    echo "  stop     - 停止正在运行的容器"
    echo "  restart  - 重启容器"
    echo "  down     - 停止并移除容器、网络"
    echo "  logs     - 查看容器的实时日志 (按 Ctrl+C 退出)"
    echo "  ssh      - 通过 SSH 连接到容器"
    echo "  exec     - 在容器内执行一个命令 (例如: $0 exec ls -l /workspace)"
    exit 1
}

# --- 主逻辑 ---
# 检查是否提供了参数
if [ $# -eq 0 ]; then
    usage
fi

COMMAND=$1
shift # 移除第一个参数，保留其余参数给 exec

log_info "正在执行命令: ${COMMAND}..."

case "${COMMAND}" in
    start)
        docker compose up -d
        ;;
    stop)
        docker compose stop
        ;;
    restart)
        docker compose restart
        ;;
    down)
        docker compose down
        ;;
    logs)
        docker compose logs -f
        ;;
    ssh)
        ssh "${DEV_USER}@localhost" -p "${SSH_PORT}"
        ;;
    exec)
        if [ $# -eq 0 ]; then
            log_error "'exec' 命令需要一个要执行的命令作为参数。"
        fi
        docker compose exec "${CONTAINER_NAME}" "$@"
        ;;
    *)
        log_error "未知的命令 '${COMMAND}'"
        usage
        ;;
esac

log_info "命令 '${COMMAND}' 执行完毕。"
