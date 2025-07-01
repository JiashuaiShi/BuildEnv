#!/bin/bash
# 遇到任何错误则立即退出
set -e

# --- 配置 ---
CONTAINER_NAME="nas-dev"
SSH_USER="shijiashuai"
SSH_PORT="2225"

# --- 用法说明 ---
usage() {
    echo "用法: $0 {start|stop|restart|down|logs|ssh|exec}"
    echo "  start   - 在后台启动容器"
    echo "  stop    - 停止正在运行的容器"
    echo "  restart - 重启容器"
    echo "  down    - 停止并移除容器"
    echo "  logs    - 查看容器的实时日志"
    echo "  ssh     - 通过 SSH 连接到容器"
    echo "  exec    - 在容器内执行一个命令 (例如: ./dev-cli.sh exec ls -l)"
    exit 1
}

# --- 主逻辑 ---
# 检查是否提供了参数
if [ -z "$1" ]; then
    usage
fi

case "$1" in
    start)
        docker-compose up -d
        ;;
    stop)
        docker-compose stop
        ;;
    restart)
        docker-compose restart
        ;;
    down)
        docker-compose down
        ;;
    logs)
        docker-compose logs -f
        ;;
    ssh)
        ssh "${SSH_USER}@localhost" -p "${SSH_PORT}"
        ;;
    exec)
        shift # 移除第一个参数 (exec)
        if [ -z "$1" ]; then
            echo "错误: 'exec' 需要一个要执行的命令。" >&2
            usage
        fi
        docker-compose exec "${CONTAINER_NAME}" "$@"
        ;;
    *)
        echo "错误: 未知的命令 '$1'" >&2
        usage
        ;;
esac
