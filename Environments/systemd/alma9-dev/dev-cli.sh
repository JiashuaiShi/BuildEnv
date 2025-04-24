#!/bin/bash

# AlmaLinux 9 Unified Development Environment Management Tool
# Usage: ./dev-cli.sh [command]

# Define container and service name based on docker-compose.yaml
CONTAINER_NAME="jiashuai.alma_9"
SERVICE_NAME="alma_9"
# Image name is built by docker-compose, not strictly needed here
# IMAGE_NAME="jiashuai/alma_9" # Example, might vary based on build
SSH_PORT="28974"
# Determine the SSH user based on Dockerfile setup (UID 2034)
# This requires knowing the username associated with UID 2034 inside the container.
# Placeholder - needs to be updated with the actual username.
SSH_USER="shijiashuai"

# 显示帮助信息
show_help() {
    echo "AlmaLinux 9 Unified Development Environment Management Tool"
    echo "Usage: ./dev-cli.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  build    - Build or rebuild the development environment container"
    echo "  start    - Start the container (using docker-compose up)"
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

# 构建容器 (Calls build.sh)
build_container() {
    echo "Building development environment container..."
    ./build.sh
}

# 启动容器 (Calls start.sh)
start_container() {
    echo "Starting container..."
    ./start.sh
}

# 停止容器 (Uses docker-compose)
stop_container() {
    echo "Stopping container ${SERVICE_NAME}..."
    docker-compose stop ${SERVICE_NAME}
}

# 停止并删除容器 (Uses docker-compose)
down_container() {
    echo "Stopping and removing container ${SERVICE_NAME}..."
    docker-compose down
}

# 重启容器 (Uses docker-compose)
restart_container() {
    echo "Restarting container ${SERVICE_NAME}..."
    docker-compose restart ${SERVICE_NAME}
    echo "Waiting a few seconds for services..."
    sleep 3
    echo "Container restarted. Use './dev-cli.sh ssh' to connect."
}

# SSH连接到容器
ssh_to_container() {
    echo "Connecting to container ${CONTAINER_NAME} via SSH..."
    echo "Attempting: ssh -p ${SSH_PORT} ${SSH_USER}@localhost"
    echo "Note: Ensure the SSH user '${SSH_USER}' exists and SSH is configured in the container."
    ssh -p ${SSH_PORT} ${SSH_USER}@localhost
}

# 显示容器状态 (Uses docker-compose)
show_status() {
    echo "Container status for service ${SERVICE_NAME}:"
    docker-compose ps
}

# 显示容器日志 (Uses docker-compose)
show_logs() {
    echo "Showing logs for container ${SERVICE_NAME}:"
    docker-compose logs --follow ${SERVICE_NAME}
}

# 清理容器和镜像
clean_container() {
    echo "Cleaning up container ${SERVICE_NAME}..."
    # Use docker-compose down to stop and remove container/network
    docker-compose down --remove-orphans
    echo "Container stopped and removed."
    # Optionally add image removal, but be careful
    # read -p "Do you also want to remove the Docker image? (y/N): " confirm
    # if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
    #     echo "Removing image... (Image name might need adjustment)"
    #     # docker rmi $(docker images -q ${IMAGE_NAME}) 2>/dev/null || echo "Image removal failed or image not found."
    #     echo "Image removal should be done manually if needed via 'docker rmi <image_id_or_tag>'."
    # fi
    echo "Cleanup finished."
}

# 在容器中执行命令 (Uses docker-compose exec)
exec_in_container() {
    shift # Remove the 'exec' argument itself
    if [ -z "$1" ]; then
        echo "Error: No command specified to execute."
        echo "Usage: ./dev-cli.sh exec \"<command>\""
        exit 1
    fi
    echo "Executing in container ${SERVICE_NAME}: $@"
    # Execute as the user specified in docker-compose.yaml (user: 2034:2000)
    # Use --user to match if needed, or let docker-compose handle it.
    # docker-compose exec ${SERVICE_NAME} bash -c "$@"
    # Execute as the dev user 'shijiashuai' by default
    docker-compose exec --user shijiashuai ${SERVICE_NAME} bash -c "$@"
}

# 主函数
main() {
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