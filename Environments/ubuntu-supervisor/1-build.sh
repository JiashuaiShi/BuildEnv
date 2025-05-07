#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 获取项目根目录 (脚本目录的上两级)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# 切换到项目根目录执行
cd "$PROJECT_ROOT" || exit 1

# 指定 compose 文件路径 (相对于项目根目录) - 主要用于清理旧容器
COMPOSE_FILE_FOR_CLEANUP="Environments/ubuntu-supervisor/docker-compose.yaml"

echo "========== Building Ubuntu (Supervisord) Development Environment =========="
echo "Project Root: $PROJECT_ROOT"
# echo "Compose File for Cleanup: $COMPOSE_FILE_FOR_CLEANUP"

# 设置环境变量优化构建
export DOCKER_BUILDKIT=1 # Enable BuildKit if desired, was 0
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（如果存在） - 使用 compose 文件
# .env 文件应该和 2-dev-cli.sh 在同一目录（即 $SCRIPT_DIR）
# docker-compose -f ... down 会查找其 yaml 文件目录下的 .env (如果适用)
# 或者 2-dev-cli.sh 已经加载了正确的环境变量给 docker-compose
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env for cleanup check"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found for cleanup check. Using default container name."
    UBUNTU_DEV_CONTAINER_NAME="shuai-ubuntu-dev" # Default if .env not found
fi

CONTAINER_TO_CHECK="${UBUNTU_DEV_CONTAINER_NAME:-shuai-ubuntu-dev}" # Fallback

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_TO_CHECK}$"; then
    echo "Stopping and removing existing container '${CONTAINER_TO_CHECK}' potentially defined by ${COMPOSE_FILE_FOR_CLEANUP}..."
    # docker-compose -f ... down 命令需要从其 .yaml 文件所在的目录运行，如果 .yaml 使用了相对路径如 context: .
    # 或者，如果 2-dev-cli.sh 总是用绝对路径或从项目根执行，那这里也需要对应调整
    # 鉴于 2-dev-cli.sh 现在 cd 到 SCRIPT_DIR 执行 docker-compose，这里也类似处理
    (cd "$SCRIPT_DIR" && docker-compose -f docker-compose.yaml down --remove-orphans 2>/dev/null || echo "docker-compose down for cleanup failed or no services were running, continuing build...")
fi

# 开始构建容器 - 使用直接的 docker build
echo "Starting build process using docker build..."
echo "Note: This may take a while, please be patient..."

# Define image name and tag - these should ideally also come from .env or be consistent with 2-dev-cli.sh
# For now, keep them as they were, but consider centralizing
UBUNTU_DEV_IMAGE_REPO=${UBUNTU_DEV_IMAGE_REPO:-shuai/ubuntu-dev} # Default if .env not sourced or var not set
UBUNTU_DEV_IMAGE_TAG=${UBUNTU_DEV_IMAGE_TAG:-20250506}     # Default if .env not sourced or var not set
IMAGE_FULL="${UBUNTU_DEV_IMAGE_REPO}:${UBUNTU_DEV_IMAGE_TAG}"


# Define build arguments
BUILD_ARGS="--build-arg SETUP_MODE=supervisord"

# Define Dockerfile path relative to project root
DOCKERFILE_PATH="Environments/ubuntu-supervisor/Dockerfile"

# Execute docker build from project root
if docker build ${BUILD_ARGS} -f "${DOCKERFILE_PATH}" -t "${IMAGE_FULL}" . ; then
    echo "========== Build Complete =========="
    echo "Image ${IMAGE_FULL} built successfully."
    echo "To start the container, navigate to Environments/ubuntu-supervisor and run:"
    echo "./2-dev-cli.sh start"
else
    echo "Build failed using docker build."
    exit 1
fi 