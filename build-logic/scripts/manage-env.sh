#!/bin/bash
# Centralized environment management script

set -e

# Check for required arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <path-to-env-dir> <command> [args...]"
    echo "Example: $0 ../env-dev/app/dev-cpp-python start"
    exit 1
fi

ENV_DIR=$(realpath "$1")
COMMAND=$2
shift 2 # Remove the first two arguments, the rest are for the command

# Check if the environment directory and .env file exist
if [ ! -d "$ENV_DIR" ]; then
    echo "Error: Environment directory not found at '$ENV_DIR'"
    exit 1
fi

if [ ! -f "$ENV_DIR/.env" ]; then
    echo "Error: .env file not found in '$ENV_DIR'"
    exit 1
fi

# Load environment variables from the specified .env file
export $(grep -v '^#' "$ENV_DIR/.env" | xargs)

# Navigate to the environment directory to ensure docker-compose works correctly
cd "$ENV_DIR"

# --- Helper Functions ---
show_help() {
    echo "Available commands:"
    echo "  start         - Start the container(s)."
    echo "  stop          - Stop the container(s)."
    echo "  restart       - Restart the container(s)."
    echo "  rm            - Stop and remove the container(s)."
    echo "  logs          - View container logs."
    echo "  exec          - Execute a command inside the container (e.g., exec bash)."
    echo "  status        - Show the status of the container(s)."
    echo "  rmi           - Remove the Docker image for this environment."
    echo "  help          - Show this help message."
}

# --- Command Dispatch ---
case "$COMMAND" in
    start)
        echo "Starting container for service '$APP_SERVICE_NAME'..."
        docker-compose up -d
        ;;
    stop)
        echo "Stopping container for service '$APP_SERVICE_NAME'..."
        docker-compose down
        ;;
    restart)
        echo "Restarting container for service '$APP_SERVICE_NAME'..."
        docker-compose restart
        ;;
    rm)
        echo "Stopping and removing container for service '$APP_SERVICE_NAME'..."
        docker-compose down
        ;;
    logs)
        echo "Showing logs for service '$APP_SERVICE_NAME'..."
        docker-compose logs -f "$@"
        ;;
    exec)
        if [ -z "$1" ]; then
            echo "Error: No command provided for exec."
            echo "Usage: $0 $1 exec <command>"
            exit 1
        fi
        echo "Executing command in container '$APP_CONTAINER_NAME': $@"
        docker exec -it -u $DEV_USER_NAME "$APP_CONTAINER_NAME" "$@"
        ;;
    status)
        echo "Status for service '$APP_SERVICE_NAME':"
        docker-compose ps
        ;;
    rmi)
        echo "Removing image '$APP_IMAGE_REPO:$APP_IMAGE_TAG'..."
        docker-compose down
        docker rmi "$APP_IMAGE_REPO:$APP_IMAGE_TAG" || echo "Image not found or already removed."
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        show_help
        exit 1
        ;;
esac
