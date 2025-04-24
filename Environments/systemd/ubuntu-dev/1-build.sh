#!/bin/bash
set -e

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" # 确保在脚本目录执行

# 镜像和服务信息 (从 docker-compose.yaml 读取或保持一致)
IMAGE_NAME="shuai/ubuntu-dev"
IMAGE_TAG="1.0"
IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"
CONTAINER_NAME="shuai-ubuntu-dev" # 与 docker-compose.yaml 保持一致

# 统一输出标题
echo "========== Building Ubuntu Development Environment =========="
echo "Image: ${IMAGE_FULL}"

# 设置环境变量优化构建 (与 alma9-dev 保持一致)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（使用 docker-compose down）
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container defined in docker-compose.yaml..."
    docker-compose down --remove-orphans || echo "'docker-compose down' failed, continuing build..."
fi

# 移除基础镜像构建步骤
# echo ">>> 构建基础镜像: ${BASE_IMAGE_FULL}..."
# docker build -t "${BASE_IMAGE_FULL}" "${BASE_DIR}"

# 开始构建开发镜像 (使用 docker-compose build)
echo "Starting build process using docker-compose..."
echo "Note: This may take a while, please be patient..."
# 传递代理参数 (如果 docker-compose.yaml 中取消注释了 args)
# export HTTP_PROXY="http://your.proxy.server:port"
# export HTTPS_PROXY="http://your.proxy.server:port"
# # 将基础镜像名称传递给开发镜像构建过程 (如果 Dockerfile 中需要)
# # docker build --build-arg BASE_IMAGE="..."
if docker-compose build; then
    echo "========== Build Complete =========="
    echo "Image ${IMAGE_FULL} built successfully."
    echo "To start the container, run: ./2-dev-cli.sh start" # 更新提示信息
else
    echo "Build failed using docker-compose."
    exit 1
fi 