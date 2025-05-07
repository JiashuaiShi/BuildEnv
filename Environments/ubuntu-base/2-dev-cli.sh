#!/bin/bash
# CLI for managing the ubuntu-base-systemd base image container

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# Load .env file from this component's directory
if [ -f "${ENV_FILE}" ]; then
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: Environment file '${ENV_FILE}' not found."
fi

# Configuration from .env or defaults
IMAGE_REPO=${UBUNTU_BASE_SYSTEMD_IMAGE_REPO:-shuai/ubuntu-base-systemd}
IMAGE_TAG=${UBUNTU_BASE_SYSTEMD_IMAGE_TAG:-noble}
CONTAINER_NAME=${UBUNTU_BASE_SYSTEMD_CONTAINER_NAME:-ubuntu-base-systemd-cont}
# Service name from docker-compose.yaml
SERVICE_NAME="ubuntu-base-systemd"

# Ensure we are in the script's directory for docker-compose context
cd "${SCRIPT_DIR}" || exit 1

# --- Helper Functions ---
check_image() {
    if ! docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' not found."
        echo "Please build it first using ./1-build.sh"
        exit 1
    fi
}

# --- Command Definitions ---
start_container() {
    check_image
    echo "Starting container '${CONTAINER_NAME}' for service '${SERVICE_NAME}'..."
    #privileged: true is set in docker-compose.yaml for systemd
    docker-compose up -d ${SERVICE_NAME}
    echo "Container should be starting. Use './2-dev-cli.sh status' to check."
}

stop_container() {
    echo "Stopping container '${CONTAINER_NAME}' for service '${SERVICE_NAME}'..."
    docker-compose stop ${SERVICE_NAME}
}

remove_container() {
    echo "Stopping and removing container for service '${SERVICE_NAME}'..."
    docker-compose down --remove-orphans
}

show_status() {
    echo "Container status for service '${SERVICE_NAME}':"
    docker-compose ps ${SERVICE_NAME}
}

show_logs() {
    echo "Logs for service '${SERVICE_NAME}' (Ctrl+C to stop):"
    docker-compose logs -f ${SERVICE_NAME}
}

exec_in_container() {
    # Default to root as no specific user is created in this base image
    local exec_user="root"
    if [ -n "$1" ] && [[ "$1" == "-u" || "$1" == "--user" ]] && [ -n "$2" ]; then
        exec_user="$2"
        shift 2
    fi
    
    local cmd_to_run="bash"
    if [ -n "$1" ]; then
        cmd_to_run="$@"
    fi

    echo "Executing command in running container '${CONTAINER_NAME}' as user '${exec_user}': ${cmd_to_run}"
    docker-compose exec --user "${exec_user}" ${SERVICE_NAME} ${cmd_to_run}
}

remove_image_cmd() {
    if docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        read -p "Are you sure you want to delete the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'? (y/n): " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
            echo "Attempting to stop and remove any containers for service '${SERVICE_NAME}'..."
            docker-compose down --remove-orphans 2>/dev/null
            echo "Deleting image '${IMAGE_REPO}:${IMAGE_TAG}'..."
            docker rmi "${IMAGE_REPO}:${IMAGE_TAG}"
        else
            echo "Image deletion cancelled."
        fi
    else
        echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' not found."
    fi
}

print_help() {
    echo "Usage: $0 <command> [options]"
    echo "CLI for the ubuntu-base-systemd base image."
    echo "Commands:
      start              Start the base systemd container.
      stop               Stop the container.
      rm                 Stop and remove the container.
      status             Show container status.
      logs               Tail container logs.
      exec [-u user] [cmd] Execute a command in the container (default: bash as root).
      rmi                Remove the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'.
      help               Show this help message."
    echo "Build image with ./1-build.sh first."
}

# --- Main Command Logic ---
COMMAND=$1
shift || true # Avoid error if no args

case "${COMMAND}" in
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    rm)
        remove_container
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    exec)
        exec_in_container "$@"
        ;;
    rmi)
        remove_image_cmd
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo "Error: Unknown command '${COMMAND}'."
        print_help
        exit 1
        ;;
esac
exit 0 