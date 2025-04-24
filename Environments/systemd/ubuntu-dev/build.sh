#!/bin/bash
set -e

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_DIR=$(realpath "$SCRIPT_DIR/../ubuntu-base")
DEV_DIR="$SCRIPT_DIR"

# 基础镜像信息
BASE_IMAGE_NAME="ubuntu-base-systemd"
BASE_IMAGE_TAG="latest"
BASE_IMAGE_FULL="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

# 开发镜像信息
DEV_IMAGE_NAME="ubuntu-dev-systemd"
DEV_IMAGE_TAG="latest"
DEV_IMAGE_FULL="${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}"

# 构建基础镜像
echo ">>> 构建基础镜像: ${BASE_IMAGE_FULL}..."
docker build -t "${BASE_IMAGE_FULL}" "${BASE_DIR}"

# 构建开发镜像
echo ""
echo ">>> 构建开发镜像: ${DEV_IMAGE_FULL}..."
# 将基础镜像名称传递给开发镜像构建过程
docker build --build-arg BASE_IMAGE="${BASE_IMAGE_FULL}" -t "${DEV_IMAGE_FULL}" "${DEV_DIR}"

echo ""
echo ">>> 构建完成!"
echo "基础镜像: ${BASE_IMAGE_FULL}"
echo "开发镜像: ${DEV_IMAGE_FULL}" 