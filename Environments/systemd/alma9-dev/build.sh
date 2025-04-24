#!/bin/bash
set -e

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# 镜像信息
IMAGE_NAME="shuai/alma-dev"
IMAGE_TAG="1.0"
IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"

# 容器信息
CONTAINER_NAME="shuai-alma-dev"

echo "========== Building AlmaLinux 9 Unified Development Environment =========="
echo "This environment includes C++/Java/Python development tools"

# 设置环境变量优化构建
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q ${CONTAINER_NAME}; then
    echo "Stopping and removing existing container..."
    docker-compose down --remove-orphans 2>/dev/null || true
    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
fi

# 开始构建容器
echo "Starting build process..."
echo "Note: This may take a while, please be patient..."
if docker-compose build; then
    echo "========== Build Complete =========="
    echo "To start the container, run:"
    echo "./start.sh"
    echo ""
    echo "Or use the dev-cli tool:"
    echo "./dev-cli.sh start"
else
    echo "Build failed"
    exit 1
fi