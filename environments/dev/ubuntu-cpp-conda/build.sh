#!/bin/bash

echo "========== Building Ubuntu 24.04 Development Environment =========="

# 设置环境变量优化构建
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q shuai-ubuntu-2404; then
    echo "Stopping and removing existing container..."
    docker-compose down 2>/dev/null || true
    docker rm -f shuai-ubuntu-2404 2>/dev/null || true
fi

# 开始构建容器
echo "Starting build process..."
if docker-compose build; then
    echo "========== Build Complete =========="
    echo "To start the container, run:"
    echo "./start.sh"
else
    echo "Build failed. Please check:"
    echo "1. Dockerfile syntax errors"
    echo "2. Package installation failures"
    echo "3. Network connectivity issues"
    echo "4. Insufficient system resources"
    echo ""
    echo "Review the error messages above and try again"
    exit 1
fi 
