#!/bin/bash

# Ubuntu Development Environment Management Tool
# Usage: ./2-dev-cli.sh [command]

# 容器和服务信息 (与 docker-compose.yaml 和 1-build.sh 保持一致)
CONTAINER_NAME="shuai-ubuntu-dev"
IMAGE_NAME="shuai/ubuntu-dev:1.0"
SSH_PORT="28964" # Ubuntu 使用的端口
SSH_USER="shijiashuai"
# 注意：Ubuntu Dockerfile 默认密码是 'password', 但建议通过 SSH key 或首次登录修改
SSH_PASSWORD="password" # 仅用于信息显示

# 显示帮助信息
show_help() {
    echo "Ubuntu Development Environment Management Tool"
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

# 构建容器 (调用 1-build.sh)
build_container() {
    echo "Building development environment container..."
    ./1-build.sh
}

# 启动容器 (直接使用 docker-compose up)
start_container() {
    echo "Starting container ${CONTAINER_NAME}..."

    if ! docker images | grep -q "${IMAGE_NAME%%:*}" | grep -q "${IMAGE_NAME##*:}"; then
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
    cd "$(dirname "$0")" || exit 1

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