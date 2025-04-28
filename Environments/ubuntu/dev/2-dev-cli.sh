#!/bin/bash

# 统一开发环境管理工具
# Usage: ./2-dev-cli.sh [command]

CONTAINER_NAME="shuai-ubuntu-dev" # 与 docker-compose.yaml 保持一致
IMAGE_NAME="shuai/ubuntu-dev:1.0" # 与 docker-compose.yaml 保持一致
SSH_PORT="28962" # 与 docker-compose.yaml 保持一致
SSH_USER="shijiashuai"
SSH_PASSWORD="phoenix2024" # 假设密码已在 Dockerfile 或 common-user-setup.sh 中设置

# 显示帮助信息
show_help() {
    echo "Ubuntu (Supervisord) Development Environment Management Tool"
    echo "Usage: ./2-dev-cli.sh [command]"
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
    # 假设 build.sh 已重命名为 1-build.sh
    if [ -f ./1-build.sh ]; then
        ./1-build.sh
    elif [ -f ./build.sh ]; then # 兼容旧名称
        echo "Warning: build.sh found, expected 1-build.sh. Running build.sh..."
        ./build.sh
    else
        echo "Error: Build script (1-build.sh or build.sh) not found."
        exit 1
    fi
}

# 启动容器 (使用 docker-compose)
start_container() {
    echo "Starting container ${CONTAINER_NAME}..."
    # 检查镜像是否存在
    if ! docker image inspect "${IMAGE_NAME}" &> /dev/null; then
        echo "Error: Image ${IMAGE_NAME} not found. Please run './2-dev-cli.sh build' first."
        exit 1
    fi

    if docker-compose up -d; then
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
        echo " Or use this tool: ./2-dev-cli.sh ssh"
        echo "---------------------------------"
        # 添加特定信息
        echo ""
        echo "JDK version management (inside container):"
        echo "  Switch to JDK 8: jdk8"
        echo "  Switch to JDK 11: jdk11"
        echo "  Switch to JDK 17: jdk17"
        echo "  Check current version: jdk"
        echo ""
        echo "Development Features (Supervisord based):"
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
    echo "Stopping container ${CONTAINER_NAME}..."
    docker-compose stop
}

# 停止并删除容器及网络 (使用 docker-compose)
down_container() {
    echo "Stopping and removing container ${CONTAINER_NAME}..."
    docker-compose down --remove-orphans
}

# 重启容器 (使用 docker-compose)
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

# 显示容器状态 (使用 docker-compose)
show_status() {
    echo "Container status:"
    docker-compose ps
}

# 显示容器日志 (使用 docker-compose)
show_logs() {
    echo "Container logs for ${CONTAINER_NAME}:"
    docker-compose logs --follow
}

# 清理容器和镜像 (使用 docker-compose)
clean_container() {
    echo "Cleaning environment for ${CONTAINER_NAME}..."
    docker-compose down --volumes --remove-orphans --rmi all 2>/dev/null || echo "Cleanup finished, some resources might remain (e.g., network if shared)."
    echo "Cleanup attempt finished."
}

# 在容器中执行命令 (保持不变, 使用 docker exec)
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
        down) # 添加 down 命令
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
            echo "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 检查 docker-compose 命令是否存在
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose could not be found. Please install it."
    exit 1
fi

main "$@" 
