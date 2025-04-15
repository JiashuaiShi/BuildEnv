#!/bin/bash

echo "========== Building Multi-JDK Development Environment =========="

# 设置环境变量优化构建
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q shuai-idea; then
    echo "Stopping and removing existing container..."
    docker-compose down 2>/dev/null || true
    docker rm -f shuai-idea 2>/dev/null || true
fi

# 开始构建容器
echo "Starting build process..."
if docker-compose build; then
    echo "========== Build Complete =========="
    echo "To start the container, run:"
    echo "./start.sh"
else
    echo "Build failed"
    exit 1
fi
