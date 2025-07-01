#!/bin/bash
# 遇到任何错误则立即退出
set -e

# --- 配置区 ---
BASE_DIR="../base"
BASE_IMAGE_NAME="ubuntu-base"
BASE_IMAGE_TAG="latest"
DEV_IMAGE_NAME="ubuntu-dev"
DEV_IMAGE_TAG="latest"
ENV_FILE=".env"

# --- 助手函数 ---
# 打印带有颜色的信息
info() {
    echo -e "\033[1;34m[信息]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[错误]\033[0m $1" >&2
    exit 1
}

# --- 主逻辑 ---
info "开始构建 Ubuntu HPC 开发环境..."

# 1. 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    error "未检测到 Docker。请先安装 Docker。"
fi

# 2. 如果基础镜像不存在，则构建它
if ! docker image inspect "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" &> /dev/null; then
    info "基础镜像 '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' 不存在，现在开始构建..."
    if [ ! -f "${BASE_DIR}/Dockerfile" ]; then
        error "基础镜像的 Dockerfile 未在 '${BASE_DIR}/Dockerfile' 找到。"
    fi

    # 从 .env 文件加载密码
    if [ -f "$ENV_FILE" ]; then
        # 使用 grep 和 xargs 安全地导出变量，忽略注释和空行
        export $(grep -v '^#' $ENV_FILE | xargs)
    else
        error "'.env' 文件未找到。请创建该文件并设置 DEV_PASSWORD。"
    fi

    if [ -z "$DEV_PASSWORD" ] || [ "$DEV_PASSWORD" == "change_this_password" ]; then
        error "DEV_PASSWORD 未在 .env 文件中设置或仍为默认值。请设置一个安全的密码。"
    fi

    # 将密码作为构建参数来构建基础镜像
    docker build \
        --build-arg "DEV_PASSWORD=${DEV_PASSWORD}" \
        -t "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" \
        "${BASE_DIR}"
    info "基础镜像构建成功。"
else
    info "基础镜像 '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' 已存在，跳过构建。"
fi

# 3. 使用 Docker Compose 构建开发镜像
info "正在构建开发镜像 '${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}'..."
if docker-compose build; then
    info "========== 构建完成 =========="
    info "要启动容器，请运行: ./start.sh"
    info "要通过 SSH 连接，请运行: ./dev-cli.sh ssh"
else
    error "开发环境构建失败。请检查 docker-compose 的输出信息。"
fi
