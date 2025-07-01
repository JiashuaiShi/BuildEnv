#!/bin/bash
# 遇到任何错误则立即退出
set -e

# --- 助手函数 ---
info() {
    echo -e "\033[1;34m[信息]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[错误]\033[0m $1" >&2
    exit 1
}

# --- 主逻辑 ---
info "正在启动 Ubuntu HPC 开发环境..."

# 1. 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    error "未检测到 Docker。请先安装 Docker。"
fi

# 2. 使用 Docker Compose 启动容器
if docker-compose up -d; then
    info "容器已成功在后台启动。"
    info "使用 './dev-cli.sh logs' 查看日志。"
    info "使用 './dev-cli.sh ssh' 连接到容器。"
else
    error "启动失败。请使用 'docker-compose up' 在前台启动以查看错误详情。"
fi
