#!/bin/bash

# Ubuntu Dev (in tmp) Environment Management Tool
# Usage: ./dev-cli.sh [command]

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 获取项目根目录 (BuildEnv, 脚本目录的上两级)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# Source environment variables from the local .env file in this directory
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Sourcing environment variables from $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "Error: $ENV_FILE file not found. This file is required for configuration."
    echo "Please create it, possibly by copying a .env.example or .env.template if available."
    exit 1
fi

# Compose 文件路径 (相对于项目根目录 - BuildEnv)
# SCRIPT_DIR 是脚本的绝对路径, e.g., /path/to/BuildEnv/tmp/ubuntu
# PROJECT_ROOT 是 /path/to/BuildEnv
# 我们希望 COMPOSE_FILE_REL_PATH 是相对于 PROJECT_ROOT 的路径
# 所以应该是 "tmp/ubuntu/docker-compose.yaml"
COMPOSE_FILE_REL_PATH="${SCRIPT_DIR#$PROJECT_ROOT/}/docker-compose.yaml"
COMPOSE_FILE_ABS_PATH="$SCRIPT_DIR/docker-compose.yaml" # 更简洁，直接使用脚本目录下的

# 构建脚本路径 (assuming it's local or user will adjust)
BUILD_SCRIPT_PATH="$SCRIPT_DIR/1-build.sh" # 假设 1-build.sh 在同一目录

# Use variables loaded from the local .env
CONTAINER_NAME="${UBUNTU_CONTAINER_NAME}"
IMAGE_NAME="${UBUNTU_IMAGE_NAME}"
SSH_PORT="${UBUNTU_SSH_PORT}"
SSH_USER="${UBUNTU_SSH_USER}"
SSH_PASSWORD="${UBUNTU_USER_PASSWORD}"

# 显示帮助信息
show_help() {
    echo "Ubuntu Dev (in tmp) Environment Management Tool"
    echo "Usage: ./dev-cli.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  build    - Build or rebuild the environment (calls 1-build.sh)"
    echo "  start    - Start the container (using docker-compose up -d)"
    echo "  stop     - Stop the container (using docker-compose stop)"
    echo "  down     - Stop and remove the container, network (docker-compose down)"
    echo "  restart  - Restart the container (using docker-compose restart)"
    echo "  ssh      - SSH into the running container"
    echo "  status   - Show container status (using docker-compose ps)"
    echo "  logs     - Show container logs (using docker-compose logs)"
    echo "  clean    - Stop/remove container, network, and optionally the image"
    echo "  exec     - Execute command in container"
    echo "  help     - Show this help message"
}

# 构建容器 (调用 1-build.sh)
build_container() {
    echo "Building unified development container..."
    if [ -f "$BUILD_SCRIPT_PATH" ]; then
        # 1-build.sh 会自己 cd 到 project root
        "$BUILD_SCRIPT_PATH"
    else
        echo "Error: Build script ($BUILD_SCRIPT_PATH) not found."
        exit 1
    fi
}

# 启动容器 (使用 docker-compose)
start_container() {
    echo "Starting container ${CONTAINER_NAME} from ${COMPOSE_FILE_ABS_PATH}..."
    # 检查镜像是否存在
    if ! docker image inspect "${IMAGE_NAME}" &> /dev/null; then
        echo "Error: Image ${IMAGE_NAME} not found. Please run './dev-cli.sh build' first."
        exit 1
    fi

    # 在项目根目录执行 docker-compose up
    if (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" up -d); then
        echo "Waiting for container services (like SSH)..."
        sleep 8 # 增加等待时间确保 supervisord 启动 sshd

        echo "Container started successfully."
        echo "---------------------------------"
        echo " SSH Connection Info:"
        echo "   Host: localhost"
        echo "   Port: ${SSH_PORT}"
        echo "   User: ${SSH_USER}"
        echo "   Password: ${SSH_PASSWORD} (if set)"
        echo ""
        echo " Connect using: ssh -p ${SSH_PORT} ${SSH_USER}@localhost"
        echo " Or use this tool: ./dev-cli.sh ssh"
        echo "---------------------------------"
        # 添加特定信息
        echo ""
        echo "JDK version management (inside container):"
        echo "  Switch to JDK 8: jdk8"
        echo "  Switch to JDK 11: jdk11"
        echo "  Switch to JDK 17: jdk17"
        echo "  Check current version: jdk"
        echo ""
        echo "Development Features (Supervisord based - Ubuntu Dev in tmp):"
        echo "  1. C++ (GCC-13, Clang), Java (8/11/17), Python (Miniconda), etc."
        echo "  2. Managed by Supervisord (sshd)"
        echo ""

    else
        echo "Failed to start container using docker-compose."
        exit 1
    fi
}

# 停止容器 (使用 docker-compose)
stop_container() {
    echo "Stopping container ${CONTAINER_NAME} using ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" stop)
}

# 停止并删除容器及网络 (使用 docker-compose)
down_container() {
    echo "Stopping and removing container ${CONTAINER_NAME} using ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" down --remove-orphans)
}

# 重启容器 (使用 docker-compose)
restart_container() {
    echo "Restarting container ${CONTAINER_NAME} using ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" restart)

    echo "Waiting for SSH service..."
    sleep 5
    echo "Container restarted. Use './dev-cli.sh ssh' to connect."
}

# SSH连接到容器 (这个不需要 compose 文件)
ssh_to_container() {
    echo "Connecting to container ${CONTAINER_NAME} (Port ${SSH_PORT})..."
    ssh -p ${SSH_PORT} ${SSH_USER}@localhost
}

# 显示容器状态 (使用 docker-compose)
show_status() {
    echo "Container status (using ${COMPOSE_FILE_ABS_PATH}):"
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" ps)
}

# 显示容器日志 (使用 docker-compose)
show_logs() {
    echo "Container logs for ${CONTAINER_NAME} (using ${COMPOSE_FILE_ABS_PATH}):"
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" logs --follow)
}

# 清理容器和镜像 (使用 docker-compose)
clean_container() {
    echo "Cleaning environment defined in ${COMPOSE_FILE_ABS_PATH}..."
    (cd "$PROJECT_ROOT" && docker-compose -f "$COMPOSE_FILE_REL_PATH" down --volumes --remove-orphans --rmi all 2>/dev/null || echo "Cleanup finished, some resources might remain.")
    echo "Cleanup attempt finished."
}

# 在容器中执行命令 (这个不需要 compose 文件)
exec_in_container() {
    if [ -z "$1" ]; then
        echo "错误: 需要指定要执行的命令"
        echo "用法: ./dev-cli.sh exec \"<命令>\""
        exit 1
    fi
    shift # Remove 'exec'
    local cmd_to_run="$@"
    echo "在容器 $CONTAINER_NAME 中执行: $cmd_to_run"
    docker exec -it $CONTAINER_NAME bash -c "$cmd_to_run"
}

# 主函数
main() {
    # 不再需要 cd 到脚本目录，因为路径都是绝对或相对于项目根目录
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
            exec_in_container "$@"
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            echo "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 检查 docker 和 docker-compose 命令是否存在
if ! command -v docker &> /dev/null; then
    echo "Error: docker command could not be found." 
    exit 1
fi
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose could not be found. Please install it."
    exit 1
fi

main "$@" 