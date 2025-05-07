#!/bin/bash

# AlmaLinux 9 (Systemd) Development Environment Management Tool
# Usage: ./2-dev-cli.sh [command]

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 获取项目根目录
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# Source environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found. Using default script values."
    SYSTEMD_ALMA9_CONTAINER_NAME="shuai-alma-dev"
    SYSTEMD_ALMA9_IMAGE_REPO="shuai/alma-dev"
    SYSTEMD_ALMA9_IMAGE_TAG="20250506"
    SYSTEMD_ALMA9_SSH_PORT="28981"
    SYSTEMD_ALMA9_SSH_USER="shijiashuai"
    SYSTEMD_ALMA9_USER_PASSWORD="phoenix2024"
fi

# Compose 文件路径 (相对于项目根目录)
COMPOSE_FILE_REL_PATH="Environments/alma9-systemd/docker-compose.yaml"
COMPOSE_FILE_ABS_PATH="$PROJECT_ROOT/$COMPOSE_FILE_REL_PATH"

# 构建脚本路径
BUILD_SCRIPT_PATH="$SCRIPT_DIR/1-build.sh"

# 容器和服务信息
CONTAINER_NAME="${SYSTEMD_ALMA9_CONTAINER_NAME}"
IMAGE_NAME="${SYSTEMD_ALMA9_IMAGE_REPO}:${SYSTEMD_ALMA9_IMAGE_TAG}"
SSH_PORT="${SYSTEMD_ALMA9_SSH_PORT}"
SSH_USER="${SYSTEMD_ALMA9_SSH_USER}"
SSH_PASSWORD="${SYSTEMD_ALMA9_USER_PASSWORD}"

# 显示帮助信息
show_help() {
    echo "AlmaLinux 9 (Systemd) Development Environment Management Tool"
    echo "Usage: ./2-dev-cli.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  build    - Build or rebuild the environment (calls 1-build.sh)"
    echo "  start    - Start the container (using docker-compose up -d)"
    echo "  stop     - Stop the container (using docker-compose stop)"
    echo "  down     - Stop and remove the container (using docker-compose down)"
    echo "  restart  - Restart the container (using docker-compose restart)"
    echo "  ssh      - SSH into the running container"
    echo "  status   - Show container status (using docker-compose ps)"
    echo "  logs     - Show container logs (using docker-compose logs)"
    echo "  clean    - Stop/remove container and optionally the image (Use with caution)"
    echo "  exec     - Execute a command inside the running container"
    echo "  help     - Show this help message"
}

# 检查宿主机内核版本是否满足要求
check_kernel_version() {
    local host_kernel=$(uname -r)
    local min_kernel_major=4
    local min_kernel_minor=18

    local host_major=$(echo "$host_kernel" | cut -d '.' -f 1)
    local host_minor=$(echo "$host_kernel" | cut -d '.' -f 2)

    echo "Host kernel version: $host_kernel"
    echo "Minimum required kernel version for systemd container: ${min_kernel_major}.${min_kernel_minor}"

    if [[ "$host_major" -lt "$min_kernel_major" ]] || \
       ( [[ "$host_major" -eq "$min_kernel_major" ]] && [[ "$host_minor" -lt "$min_kernel_minor" ]] ); then
        echo "Error: Host kernel version ($host_kernel) is too low."
        echo "This systemd-based container requires kernel version ${min_kernel_major}.${min_kernel_minor} or higher to run properly."
        echo "Please run this container on a host with a newer kernel."
        exit 1
    fi
    echo "Host kernel version meets the requirement."
}

# 构建容器 (调用 1-build.sh)
build_container() {
    echo "Building development environment container..."
    ./1-build.sh
}

# 启动容器 (直接使用 docker-compose up)
start_container() {
    echo "Starting container ${CONTAINER_NAME} from ${COMPOSE_FILE_ABS_PATH}..."

    # 添加内核版本检查
    check_kernel_version

    # 检查镜像是否存在
    if ! docker image inspect "${IMAGE_NAME}" &> /dev/null; then
        echo "Error: Image ${IMAGE_NAME} not found. Please run './2-dev-cli.sh build' first."
        exit 1
    fi

    # 在脚本所在目录执行 docker-compose up, 因为 docker-compose.yaml 中的 context 指向项目根目录，
    # 但其 dockerfile 路径是相对于项目根的。
    # docker-compose -f docker-compose.yaml up -d
    # 为了确保 docker-compose -f 使用的是正确的 compose 文件路径，并且其 context 计算正确，
    # 我们切换到项目根目录执行 docker-compose 命令，并使用相对于根目录的 compose 文件路径。
    if (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" up -d); then
        echo "Waiting for container services (like SSH)..."
        # 简单的等待，可以根据需要调整或实现更健壮的检查
        sleep 8

        echo "Container started successfully."
        echo "---------------------------------"
        echo " SSH Connection Info:"
        echo "   Host: localhost"
        echo "   Port: ${SSH_PORT}"
        echo "   User: ${SSH_USER}"
        echo "   Password: ${SSH_PASSWORD}"
        echo ""
        echo " Connect using: ssh -p ${SSH_PORT} ${SSH_USER}@localhost"
        echo " Or use this tool: ./2-dev-cli.sh ssh"
        echo "---------------------------------"
        # 显示 start.sh 中的其他信息
        echo ""
        echo "JDK version management (inside container):"
        echo "  Switch to JDK 8: jdk8"
        echo "  Switch to JDK 11: jdk11"
        echo "  Switch to JDK 17: jdk17"
        echo "  Check current version: jdk"
        echo ""
        echo "Development Features:"
        echo "  1. C++ Development: GCC, Clang, CMake, Ninja, GDB, Valgrind, etc."
        echo "  2. Java Development: JDK 8/11/17 Support"
        echo "  3. Python Development: Python 3 + pip (via Miniconda)"
        echo ""

    else
        echo "Failed to start container using docker-compose."
        exit 1
    fi
}

# 停止容器 (使用 docker-compose stop)
stop_container() {
    echo "Stopping container ${CONTAINER_NAME} using ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" stop)
}

# 停止并删除容器 (保持 docker-compose down)
down_container() {
    echo "Stopping and removing container ${CONTAINER_NAME} using ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" down --remove-orphans)
}

# 重启容器 (使用 docker-compose restart)
restart_container() {
    echo "Restarting container ${CONTAINER_NAME} using ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" restart)

    echo "Waiting for SSH service..."
    sleep 5
    echo "Container restarted. Use './2-dev-cli.sh ssh' to connect."
}

# SSH连接到容器
ssh_to_container() {
    echo "连接到容器..."
    ssh -p $SSH_PORT $SSH_USER@localhost
}

# 显示容器状态 (使用 docker-compose ps)
show_status() {
    echo "Container status (using ${COMPOSE_FILE_ABS_PATH}):"
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" ps)
}

# 显示容器日志 (使用 docker-compose logs)
show_logs() {
    echo "Container logs for ${CONTAINER_NAME} (using ${COMPOSE_FILE_ABS_PATH}):"
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" logs --follow)
}

# 清理容器和镜像 (更新提示)
clean_container() {
    echo "Cleaning environment defined in ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" down --volumes --remove-orphans --rmi all 2>/dev/null || echo "Cleanup finished, some resources might remain.")
    echo "Cleanup attempt finished."
}

# 在容器中执行命令
exec_in_container() {
    if [ -z "$2" ]; then
        echo "错误: 需要指定要执行的命令"
        echo "用法: ./2-dev-cli.sh exec \"<命令>\""
        exit 1
    fi

    echo "在容器中执行: $2"
    docker exec -it $CONTAINER_NAME bash -c "$2"
}

# 主函数
main() {
    # 确保 docker-compose 命令在正确的上下文中执行
    # 此脚本中的 docker-compose 命令现在都通过 cd "$PROJECT_ROOT" 并在那里执行
    # 并使用 -f "$COMPOSE_FILE_REL_PATH"

    case "$1" in
        build)
            build_container
            ;;
        start)
            start_container
            ;;
        stop)
            stop_container
            ;;
        down)
            down_container
            ;;
        restart)
            restart_container
            ;;
        ssh)
            ssh_to_container
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        clean)
            clean_container
            ;;
        exec)
            shift
            exec_in_container "$@"
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Check if docker-compose exists
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose could not be found. Please install it."
    exit 1
fi

main "$@"