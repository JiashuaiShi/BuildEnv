#!/bin/bash

# 获取脚本所在目录并切换过去
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" || exit 1

echo "========== Building Unified Development Environment (Supervisord) =========="
echo "This environment includes C++/Java/Python development tools"

# 设置环境变量优化构建
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q shuai-dev; then
    echo "Stopping and removing existing container..."
    docker-compose down 2>/dev/null || true
    docker rm -f shuai-dev 2>/dev/null || true
fi

# 开始构建容器
echo "Starting build process..."
echo "Note: This may take a while, please be patient..."
if docker-compose build; then
    echo "========== Build Complete =========="
    echo "To start the container, run:"
    echo "./start.sh"
else
    echo "Build failed"
    exit 1
fi 
