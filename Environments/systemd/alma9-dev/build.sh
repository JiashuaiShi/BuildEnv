    #!/bin/bash

echo "========== Building AlmaLinux 9 Unified Development Environment =========="
# Removed specific tool list, can be added back if needed.

## ==================================================================
# 构建脚本统一模板，与 ubuntu-dev/build.sh 保持一致
## ==================================================================
## 开启错误即停
set -e

## 探测脚本目录
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
DEV_DIR="$SCRIPT_DIR"

## 基础镜像信息
BASE_IMAGE_NAME="almalinux/9-init"
BASE_IMAGE_TAG="latest"
BASE_IMAGE_FULL="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

## 开发镜像信息
DEV_IMAGE_NAME="alma9-dev-systemd"
DEV_IMAGE_TAG="latest"
DEV_IMAGE_FULL="${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}"

# 1. 拉取基础镜像（如果需要）
echo ">>> 拉取基础镜像: ${BASE_IMAGE_FULL}..."
docker pull "${BASE_IMAGE_FULL}" || echo ">>> 基础镜像已存在或拉取失败"

# 2. 构建开发镜像
echo ""
echo ">>> 构建开发镜像: ${DEV_IMAGE_FULL}..."
docker build --build-arg BASE_IMAGE="${BASE_IMAGE_FULL}" -t "${DEV_IMAGE_FULL}" "${DEV_DIR}"

# 3. 完成提示
echo ""
echo ">>> 构建完成!"
echo "Base image: ${BASE_IMAGE_FULL}"
echo "Dev image: ${DEV_IMAGE_FULL}"