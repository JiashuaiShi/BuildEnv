#!/bin/bash

echo "========== Building AlmaLinux 9 Unified Development Environment =========="
# Removed specific tool list, can be added back if needed.

# 设置环境变量优化构建
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1

# Define container name based on docker-compose.yaml
CONTAINER_NAME="jiashuai.alma_9"

# 停止并删除旧容器（如果存在）
# Use docker-compose down which handles the service name defined in the compose file.
if docker ps -a | grep -q ${CONTAINER_NAME}; then
    echo "Stopping and removing existing container..."
    # docker-compose down uses the project name (directory name by default)
    # or the service name defined in the file. It should handle this.
    docker-compose down --remove-orphans 2>/dev/null || true
    # Explicitly remove by container name just in case
    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
fi

# 开始构建容器
echo "Starting build process..."
echo "Note: This may take a while, please be patient..."
# docker-compose build uses the docker-compose.yaml in the current directory
if docker-compose build; then
    echo "========== Build Complete =========="
    echo "To start the container, run:"
    echo "./start.sh"
else
    echo "Build failed"
    exit 1
fi 