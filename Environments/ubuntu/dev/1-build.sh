#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 获取项目根目录 (脚本目录的上三级)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../../.." &> /dev/null && pwd)

# 切换到项目根目录执行
cd "$PROJECT_ROOT" || exit 1

# 指定 compose 文件路径 (相对于项目根目录)
COMPOSE_FILE="Environments/ubuntu/dev/docker-compose.yaml"

echo "========== Building Unified Development Environment (Supervisord) =========="
echo "Project Root: $PROJECT_ROOT"
echo "Compose File: $COMPOSE_FILE"
echo "This environment includes C++/Java/Python development tools"

# 设置环境变量优化构建
export DOCKER_BUILDKIT=0 # Keep BuildKit disabled for now
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（如果存在） - 使用 compose 文件
# 注意: 这里的 grep 可能需要调整或移除，取决于容器名是否唯一
if docker ps -a --format '{{.Names}}' | grep -q "shuai-ubuntu-dev"; then
    echo "Stopping and removing existing container..."
    docker-compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
fi

# 开始构建容器 - 使用直接的 docker build
echo "Starting build process using docker build..."
echo "Note: This may take a while, please be patient..."

# Define image name and tag
IMAGE_NAME="shuai/ubuntu-dev"
IMAGE_TAG="1.0"
IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"

# Define build arguments (previously in docker-compose.yaml)
# Note: User/Group args are now handled by unified script
# Ensure common script has correct hardcoded values or pass them if script uses ARGs
BUILD_ARGS="--build-arg SETUP_MODE=supervisord"

# Define Dockerfile path relative to project root
DOCKERFILE_PATH="Environments/ubuntu/dev/Dockerfile"

# Execute docker build from project root
if docker build ${BUILD_ARGS} -f "${DOCKERFILE_PATH}" -t "${IMAGE_FULL}" . ; then
    echo "========== Build Complete =========="
    echo "Image ${IMAGE_FULL} built successfully."
    echo "To start the container, navigate to Environments/ubuntu/dev and run:"
    echo "./2-dev-cli.sh start"
else
    echo "Build failed using docker build."
    exit 1
fi 
