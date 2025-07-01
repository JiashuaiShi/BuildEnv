#!/bin/bash
set -e

CONTAINER_NAME="web-dev"

usage() {
    echo "Usage: $0 {start|stop|restart|down|logs|ssh|exec}"
    exit 1
}

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
        ssh shijiashuai@localhost -p 2224
        ;;
    exec)
        shift
        docker-compose exec web-dev "$@"
        ;;
    *)
        usage
        ;;
esac
