#!/bin/bash

# Ubuntu (Systemd) Development Environment Management Tool
# Usage: ./2-dev-cli.sh [command]

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 获取项目根目录
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../../.." &> /dev/null && pwd)

# Source environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found. Using default script values."
    SYSTEMD_UBUNTU_CONTAINER_NAME="shuai-ubuntu-dev"
    SYSTEMD_UBUNTU_IMAGE_REPO="shuai/ubuntu-dev"
    SYSTEMD_UBUNTU_IMAGE_TAG="20250506"
    SYSTEMD_UBUNTU_SSH_PORT="28982"
    SYSTEMD_UBUNTU_SSH_USER="shijiashuai"
    SYSTEMD_UBUNTU_USER_PASSWORD="phoenix2024"
fi

# Compose 文件路径 (相对于项目根目录)
COMPOSE_FILE_REL_PATH="Environments/systemd/ubuntu-dev/docker-compose.yaml"
COMPOSE_FILE_ABS_PATH="$PROJECT_ROOT/$COMPOSE_FILE_REL_PATH"

# 构建脚本路径
BUILD_SCRIPT_PATH="$SCRIPT_DIR/1-build.sh"

# 容器和服务信息
CONTAINER_NAME="${SYSTEMD_UBUNTU_CONTAINER_NAME}"
IMAGE_NAME="${SYSTEMD_UBUNTU_IMAGE_REPO}:${SYSTEMD_UBUNTU_IMAGE_TAG}"
SSH_PORT="${SYSTEMD_UBUNTU_SSH_PORT}"
SSH_USER="${SYSTEMD_UBUNTU_SSH_USER}"
SSH_PASSWORD="${SYSTEMD_UBUNTU_USER_PASSWORD}"

# 显示帮助信息
show_help() {
    echo "Ubuntu (Systemd) Development Environment Management Tool"
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
    # 保留 exec 和 clean，保持一致性
    echo "  clean    - Stop/remove container and optionally the image (Use with caution)"
    echo "  exec     - Execute a command inside the running container"
    echo "  help     - Show this help message"
}

# 检查宿主机内核版本是否满足要求
check_kernel_version() {
    local host_kernel=$(uname -r)
    local min_kernel_major=4
    local min_kernel_minor=18 # Ubuntu 24.04 LTS based systemd likely needs a reasonably modern kernel

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
    echo "Starting container ${CONTAINER_NAME}..."

    # 添加内核版本检查
    check_kernel_version

    # 修正检查镜像是否存在的方式
    if ! docker image inspect "${IMAGE_NAME}" &> /dev/null; then
        echo "Error: Image ${IMAGE_NAME} not found. Please run './2-dev-cli.sh build' first."
        exit 1
    fi

    if docker-compose up -d; then
        echo "Waiting for container services (like SSH)..."
        sleep 8

        echo "Container started successfully."
        echo "---------------------------------"
        echo " SSH Connection Info:"
        echo "   Host: localhost"
        echo "   Port: ${SSH_PORT}"
        echo "   User: ${SSH_USER}"
        echo "   Password: ${SSH_PASSWORD} (default, change it!)"
        echo ""
        echo " Connect using: ssh -p ${SSH_PORT} ${SSH_USER}@localhost"
        echo " Or use this tool: ./2-dev-cli.sh ssh"
        echo "---------------------------------"
        # 添加 Ubuntu 特有的信息或通用信息
        echo ""
        echo "JDK version management (inside container):"
        echo "  Switch to JDK 8: jdk8"
        echo "  Switch to JDK 11: jdk11"
        echo "  Switch to JDK 17: jdk17"
        echo "  Check current version: jdk"
        echo ""
        echo "Development Features:"
        echo "  1. C++ (GCC-13, Clang), Java (8/11/17), Python (Miniconda), Go, Rust"
        echo "  2. Common tools: Git, CMake, Ninja, GDB, Valgrind, Maven, Gradle, SBT, etc."
        echo "  3. Shell: zsh with oh-my-zsh, bash"
        echo ""
    else
        echo "Failed to start container using docker-compose."
        exit 1
    fi
}

# 停止容器 (使用 docker-compose stop)
stop_container() {
    echo "Stopping container ${CONTAINER_NAME}..."
    docker-compose stop
}

# 停止并删除容器 (使用 docker-compose down)
down_container() {
    echo "Stopping and removing container ${CONTAINER_NAME}..."
    docker-compose down --remove-orphans
}

# 重启容器 (使用 docker-compose restart)
restart_container() {
    echo "Restarting container ${CONTAINER_NAME}..."
    docker-compose restart
    echo "Waiting for SSH service..."
    sleep 5
    echo "Container restarted. Use './2-dev-cli.sh ssh' to connect."
}

# SSH连接到容器
ssh_to_container() {
    echo "Connecting to container ${CONTAINER_NAME}..."
    ssh -p ${SSH_PORT} ${SSH_USER}@localhost
}

# 显示容器状态 (使用 docker-compose ps)
show_status() {
    echo "Container status:"
    docker-compose ps
}

# 显示容器日志 (使用 docker-compose logs)
show_logs() {
    echo "Container logs for ${CONTAINER_NAME}:"
    docker-compose logs --follow
}

# 清理容器和镜像
clean_container() {
    echo "Cleaning container ${CONTAINER_NAME} and image ${IMAGE_NAME}..."
    docker-compose down --remove-orphans 2>/dev/null || true
    if docker image inspect ${IMAGE_NAME} &> /dev/null; then
        echo "Removing image ${IMAGE_NAME}..."
        docker rmi ${IMAGE_NAME} 2>/dev/null || echo "Failed to remove image ${IMAGE_NAME}. It might be in use."
    else
        echo "Image ${IMAGE_NAME} not found."
    fi
    echo "Cleanup attempt finished."
}

# 在容器中执行命令
exec_in_container() {
    if [ -z "$1" ]; then # 检查是否有命令传入
        echo "Error: Command must be provided."
        echo "Usage: ./2-dev-cli.sh exec \"<command>\""
        exit 1
    fi
    echo "Executing in container ${CONTAINER_NAME}: $@"
    docker exec -it ${CONTAINER_NAME} bash -c "$@"
}

# 主函数
main() {
    # 切换到脚本所在目录，确保 docker-compose 能找到文件
    cd "$SCRIPT_DIR" || exit 1

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
            shift # 移除 'exec'
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