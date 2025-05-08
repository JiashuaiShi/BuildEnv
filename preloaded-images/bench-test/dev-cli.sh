#!/bin/bash

# Bench Test 环境 (bench-test) 管理工具
# 用法: ./dev-cli.sh [命令]

# 获取脚本所在目录，确保路径的可靠性
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# 加载 .env 文件中的环境变量
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    echo "信息: 从 $ENV_FILE 加载环境变量..."
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "错误: 配置文件 $ENV_FILE 未找到。此文件为必需的配置项。"
    echo "请创建该文件。如果项目提供 .env.example 或 .env.template 文件，可以复制并修改它们。"
    exit 1
fi

# 从 .env 文件加载服务特定的变量，并设置通用脚本变量
# 服务容器名称
CONTAINER_NAME="${BENCH_CONTAINER_NAME}"
# 服务镜像名称
IMAGE_NAME="${BENCH_IMAGE_NAME}"
# 服务 SSH 端口
SSH_PORT="${BENCH_SSH_PORT}"
# 服务 SSH 用户
SSH_USER="${BENCH_SSH_USER}"
# 服务 SSH 密码
SSH_PASSWORD="${BENCH_USER_PASSWORD}"
# 构建脚本路径 (如果存在)
BUILD_SCRIPT_PATH="$SCRIPT_DIR/1-build.sh"


# 显示帮助信息
show_help() {
    echo "Bench Test 环境 (bench-test) 管理工具"
    echo "用法: ./dev-cli.sh [命令]"
    echo ""
    echo "可用命令:"
    echo "  build    - 构建或重新构建环境 (调用 1-build.sh)"
    echo "  start    - 启动容器 (使用 docker-compose up -d)"
    echo "  stop     - 停止容器 (使用 docker-compose stop)"
    echo "  down     - 停止并移除容器、网络等 (docker-compose down)"
    echo "  restart  - 重启容器 (使用 docker-compose restart)"
    echo "  ssh      - 通过 SSH 连接到正在运行的容器"
    echo "  status   - 显示容器状态 (使用 docker-compose ps)"
    echo "  logs     - 实时显示容器日志 (使用 docker-compose logs -f)"
    echo "  clean    - 清理环境 (停止/移除容器、网络和卷)"
    echo "  exec     - 在正在运行的容器内执行命令"
    echo "  help     - 显示此帮助信息"
}

# 构建容器 (如果适用)
build_container() {
    if [ -f "$BUILD_SCRIPT_PATH" ]; then
        echo "信息: 开始构建容器环境 (执行 $BUILD_SCRIPT_PATH)..."
        "$BUILD_SCRIPT_PATH"
    else
        echo "错误: 构建脚本 $BUILD_SCRIPT_PATH 未找到。"
        echo "如果不需要构建步骤，请忽略此命令。"
    fi
}

# 启动容器
start_container() {
    echo "信息: 正在启动容器 ${CONTAINER_NAME} (镜像: ${IMAGE_NAME})..."

    if ! docker image inspect "${IMAGE_NAME}" &> /dev/null; then
        echo "错误: 镜像 ${IMAGE_NAME} 未找到。"
        echo "如果需要构建镜像，请先执行 './dev-cli.sh build' 命令。"
        exit 1
    fi

    echo "信息: 使用 docker-compose 启动服务 (配置文件: $SCRIPT_DIR/docker-compose.yaml)..."
    if docker-compose up -d; then
        echo "信息: 等待容器服务 (如 SSH) 启动..."
        sleep 8

        echo "信息: 容器已成功启动。"
        echo "---------------------------------"
        echo " SSH 连接信息:"
        echo "   主机: localhost"
        echo "   端口: ${SSH_PORT}"
        echo "   用户: ${SSH_USER}"
        echo "   密码: (请查看 .env 文件中的 ${BENCH_USER_PASSWORD:-BENCH_USER_PASSWORD} 配置)"
        echo ""
        echo " 连接命令: ssh -p ${SSH_PORT} ${SSH_USER}@localhost"
        echo " 或使用: ./dev-cli.sh ssh"
        echo "---------------------------------"
        # Bench Test 环境特定信息
        echo ""
        echo "Bench Test 环境特性 (基于 Supervisord):"
        echo "  1. 包含常用基准测试工具和依赖。"
        echo "  2. Java (JDK 8/11/17), Python (Miniconda) 等环境支持。"
        echo ""
    else
        echo "错误: 使用 docker-compose 启动容器失败。"
        exit 1
    fi
}

# 停止容器
stop_container() {
    echo "信息: 正在停止容器 ${CONTAINER_NAME}..."
    docker-compose stop
}

# 停止并移除容器等
down_container() {
    echo "信息: 正在停止并移除容器、网络等..."
    docker-compose down --remove-orphans
}

# 重启容器
restart_container() {
    echo "信息: 正在重启容器 ${CONTAINER_NAME}..."
    docker-compose restart
    echo "信息: 等待 SSH 服务重新连接..."
    sleep 5
    echo "信息: 容器已重启。使用 './dev-cli.sh ssh' 连接。"
}

# SSH 连接到容器
ssh_to_container() {
    echo "信息: 正在通过 SSH 连接到容器 ${CONTAINER_NAME} (用户: ${SSH_USER}, 端口: ${SSH_PORT})..."
    ssh -p "${SSH_PORT}" "${SSH_USER}@localhost"
}

# 显示容器状态
show_status() {
    echo "信息: 显示容器状态..."
    docker-compose ps
}

# 显示容器日志
show_logs() {
    echo "信息: 实时显示容器日志 (按 Ctrl+C 停止)..."
    docker-compose logs --follow
}

# 清理环境
clean_container() {
    read -p "警告: 此操作将移除属于此服务定义的容器、网络和卷。是否继续? (y/N): " confirm
    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        echo "信息: 正在清理环境 (${CONTAINER_NAME})..."
        docker-compose down --volumes --remove-orphans
        echo "信息: 清理完成。"
    else
        echo "信息: 清理操作已取消。"
    fi
}

# 在容器内执行命令
exec_in_container() {
    if [ -z "$1" ]; then
        echo "错误: 需要指定要执行的命令。"
        echo "用法: ./dev-cli.sh exec "<命令及其参数>""
        exit 1
    fi
    echo "信息: 在容器 ${CONTAINER_NAME} 中执行命令: $@"
    docker exec -it "${CONTAINER_NAME}" bash -c "$@"
}

# 主函数
main() {
    cd "$SCRIPT_DIR" || { echo "错误: 无法切换到脚本目录 $SCRIPT_DIR"; exit 1; }

    if ! command -v docker &> /dev/null; then
        echo "错误: 未找到 docker 命令。请确保 Docker 已安装并位于系统的 PATH 环境变量中。"
        exit 1
    fi
    if ! command -v docker-compose &> /dev/null; then
        echo "错误: 未找到 docker-compose 命令。请确保 Docker Compose 已安装并位于系统的 PATH 环境变量中。"
        exit 1
    fi

    case "$1" in
        build)    build_container ;;
        start)    start_container ;;
        stop)     stop_container ;;
        down)     down_container ;;
        restart)  restart_container ;;
        ssh)      ssh_to_container ;;
        status)   show_status ;;
        logs)     show_logs ;;
        clean)    clean_container ;;
        exec)     shift; exec_in_container "$@" ;; 
        help|--help|-h|"") show_help ;;
        *)
            echo "错误: 未知命令 '$1'"
            show_help
            exit 1
            ;;
    esac
}

main "$@" 