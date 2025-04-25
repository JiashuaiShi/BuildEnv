#!/bin/bash

# Ubuntu Unified Development Environment Management Tool
# Usage: ./dev-cli.sh [command]

# 容器信息
CONTAINER_NAME="shuai-ubuntu-dev"
IMAGE_NAME="shuai/ubuntu-dev:1.0"
SSH_PORT="28964"
SSH_USER="shijiashuai"

# 显示帮助信息
show_help() {
    echo "Ubuntu Unified Development Environment Management Tool"
    echo "Usage: ./dev-cli.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  build    - Build development container"
    echo "  start    - Start container"
    echo "  stop     - Stop container"
    echo "  restart  - Restart container"
    echo "  ssh      - SSH into container"
    echo "  status   - Show container status"
    echo "  logs     - Show container logs"
    echo "  clean    - Clean containers and images"
    echo "  exec     - Execute command in container"
    echo "  help     - Show this help message"
}

# 构建容器
build_container() {
    echo "Building unified development container..."
    ./build.sh
}

# 启动容器
start_container() {
    echo "Starting container..."
    ./start.sh
}

# 停止容器
stop_container() {
    echo "Stopping container..."
    docker stop $CONTAINER_NAME
}

# 停止并删除容器
down_container() {
    echo "Stopping and removing container..."
    docker-compose down
}

# 重启容器
restart_container() {
    echo "重启容器..."
    docker restart $CONTAINER_NAME
    
    echo "等待SSH服务就绪..."
    sleep 2
    echo "容器已重启，可以使用 ./dev-cli.sh ssh 连接"
}

# SSH连接到容器
ssh_to_container() {
    echo "连接到容器..."
    ssh -p $SSH_PORT $SSH_USER@localhost
}

# 显示容器状态
show_status() {
    echo "容器状态:"
    docker ps -a | grep $CONTAINER_NAME
}

# 显示容器日志
show_logs() {
    echo "容器日志:"
    docker logs $CONTAINER_NAME
}

# 清理容器和镜像
clean_container() {
    echo "清理容器和镜像..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    docker rmi $IMAGE_NAME 2>/dev/null || true
    echo "清理完成"
}

# 在容器中执行命令
exec_in_container() {
    if [ -z "$2" ]; then
        echo "错误: 需要指定要执行的命令"
        echo "用法: ./dev-cli.sh exec \"<命令>\""
        exit 1
    fi
    
    echo "在容器中执行: $2"
    docker exec -it $CONTAINER_NAME bash -c "$2"
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
            echo "未知命令: $1"
            echo "使用 './dev-cli.sh help' 查看可用命令"
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
