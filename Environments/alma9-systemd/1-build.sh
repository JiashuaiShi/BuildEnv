#!/bin/bash
set -e

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 获取项目根目录
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# 切换到项目根目录执行
cd "$PROJECT_ROOT" || exit 1

# Source environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found. Using default script values."
    # Define critical defaults or exit if .env is essential
    SYSTEMD_ALMA9_CONTAINER_NAME="shuai-alma-systemd" # Updated default name
    SYSTEMD_ALMA9_IMAGE_REPO="shuai/alma9-systemd"  # Updated default repo
    SYSTEMD_ALMA9_IMAGE_TAG="latest"
    # UBUNTU_DEV_SSH_USER and PASSWORD are not directly used in build script but loaded if present
fi

# Compose 文件路径 (相对于项目根目录)
COMPOSE_FILE_REL_PATH="Environments/alma9-systemd/docker-compose.yaml"

# 镜像和服务信息
IMAGE_NAME="${SYSTEMD_ALMA9_IMAGE_REPO}"
IMAGE_TAG="${SYSTEMD_ALMA9_IMAGE_TAG}"
IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"
CONTAINER_NAME="${SYSTEMD_ALMA9_CONTAINER_NAME}"

# 统一输出标题
echo "========== Building AlmaLinux 9 (Systemd) Development Environment =========="
echo "Project Root: $PROJECT_ROOT"
echo "Compose File: $COMPOSE_FILE_REL_PATH"
echo "Target Image: ${IMAGE_FULL}"
echo "Target Container Name: ${CONTAINER_NAME}"

# 设置环境变量优化构建 (保留)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（使用 docker-compose down）
# 确保环境变量已导出给 docker-compose (set -a above handles this for sourced .env)
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container '${CONTAINER_NAME}' using ${COMPOSE_FILE_REL_PATH}..."
    # docker-compose -f ... down 命令需要从其 .yaml 文件所在的目录运行，或者从项目根目录用相对路径
    docker-compose -f "${COMPOSE_FILE_REL_PATH}" down --remove-orphans || echo "'docker-compose down' failed for ${CONTAINER_NAME}, continuing build..."
fi

# 开始构建容器 (使用 docker-compose build)
echo "Starting build process using docker-compose -f ${COMPOSE_FILE_REL_PATH} build..."
echo "Note: This may take a while, please be patient..."

# docker-compose build 会使用 docker-compose.yaml 中定义的 build context 和 args
# 确保 docker-compose.yaml 中的 args (like USER_NAME, USER_PASSWORD from .env) 被正确传递
if docker-compose -f "${COMPOSE_FILE_REL_PATH}" build; then
    echo "========== Build Complete =========="
    echo "Image ${IMAGE_FULL} built successfully."
    echo "To start the container, navigate to ${SCRIPT_DIR} and run:"
    echo "./2-dev-cli.sh start"
else
    echo "Build failed using docker-compose -f ${COMPOSE_FILE_REL_PATH} build."
    exit 1
fi