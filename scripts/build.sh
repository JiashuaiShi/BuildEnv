#!/bin/bash

# ==============================================================================
#
#                         通用开发环境构建脚本
#
# 功能:
#   - 自动检测当前环境类型
#   - 构建基础镜像和开发镜像
#   - 提供清晰的日志输出和错误处理
#
# 使用说明:
#   将此脚本放在 common/scripts/ 目录下
#   在各环境的 dev 目录中创建指向此脚本的符号链接
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
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_NC} $1"; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1"; exit 1; }

# --- 主逻辑开始 ---
log_info "开始构建 ${ENV_TYPE} 开发环境..."

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
    log_error "配置文件 '${ENV_FILE}' 未找到。请从 '.env.example' 复制并进行配置。"
fi
source "${ENV_FILE}"
log_info "成功加载 '.env' 配置文件。"

# 验证关键环境变量
: ${DEV_USER?'.env' 文件中未设置 DEV_USER}
: ${DEV_PASSWORD?'.env' 文件中未设置 DEV_PASSWORD}
: ${USER_UID?'.env' 文件中未设置 USER_UID}
: ${DEV_GROUP?'.env' 文件中未设置 DEV_GROUP}
: ${GROUP_GID?'.env' 文件中未设置 GROUP_GID}

if [ "${DEV_PASSWORD}" == "change_this_password" ]; then
    log_error "检测到默认密码。请在 '${ENV_FILE}' 文件中设置一个安全的 DEV_PASSWORD。"
fi

# 3. 构建基础镜像 (如果不存在)
BASE_DIR="../base"
BASE_IMAGE_NAME="${ENV_TYPE}-base"
BASE_IMAGE_TAG="latest"

if ! docker image inspect "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" &> /dev/null; then
    log_info "基础镜像 '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' 不存在，现在开始构建..."
    if [ ! -f "${BASE_DIR}/Dockerfile" ]; then
        log_error "基础镜像的 Dockerfile 未在 '${BASE_DIR}/Dockerfile' 找到。"
    fi

    docker build \
        --build-arg DEV_USER="${DEV_USER}" \
        --build-arg DEV_PASSWORD="${DEV_PASSWORD}" \
        --build-arg USER_UID="${USER_UID}" \
        --build-arg DEV_GROUP="${DEV_GROUP}" \
        --build-arg GROUP_GID="${GROUP_GID}" \
        -t "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" \
        "${BASE_DIR}"
    log_success "基础镜像 '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' 构建成功。"
else
    log_info "基础镜像 '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' 已存在，跳过构建。"
fi

# 4. 构建开发镜像
DEV_IMAGE_NAME="${ENV_TYPE}-dev"
DEV_IMAGE_TAG="latest"

log_info "正在使用 Docker Compose 构建开发镜像 '${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}'..."
docker compose build

log_success "========== 构建完成 =========="
log_info "要启动容器，请运行: ./start.sh"
log_info "要通过 SSH 连接，请运行: ./dev-cli.sh ssh"
