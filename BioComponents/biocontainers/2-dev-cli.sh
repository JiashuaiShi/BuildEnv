#!/bin/bash
# CLI for managing the biocontainers-dev development environment

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# Load .env file from the component directory
if [ -f "${ENV_FILE}" ]; then
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: Environment file '${ENV_FILE}' not found."
fi

# Configuration (from .env or defaults)
IMAGE_REPO=${BIO_BIOCONTAINERS_IMAGE_REPO:-my-repo/biocontainers-dev}
IMAGE_TAG=${BIO_BIOCONTAINERS_IMAGE_TAG:-latest}
CONTAINER_NAME=${BIO_BIOCONTAINERS_CONTAINER_NAME:-biocontainers-dev-env}
SERVICE_NAME="biocontainers-dev" # Service name in docker-compose.yaml
SSH_PORT=${BIO_BIOCONTAINERS_SSH_PORT:-2203} # SSH port mapped on host
SSH_USER=${SSH_USER_NAME:-shijiashuai} # User inside the container

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
    docker-compose up -d ${SERVICE_NAME}
    echo "Container should be starting. Use './2-dev-cli.sh status' to check."
    echo "SSH access: ssh ${SSH_USER}@localhost -p ${SSH_PORT}"
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

ssh_into_container() {
    echo "Attempting to SSH into '${CONTAINER_NAME}' as user '${SSH_USER}' on port '${SSH_PORT}'..."
    echo "Command: ssh ${SSH_USER}@localhost -p ${SSH_PORT}"
    ssh "${SSH_USER}@localhost" -p "${SSH_PORT}"
}

exec_into_container() {
    echo "Opening a bash shell in running container '${CONTAINER_NAME}' for service '${SERVICE_NAME}' as user '${SSH_USER}'..."
    docker-compose exec -u "${SSH_USER}" ${SERVICE_NAME} bash
}

remove_image() {
    if docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        read -p "Are you sure you want to delete the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'? This will also stop/remove associated containers. (y/n): " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
            echo "Attempting to stop and remove any containers for service '${SERVICE_NAME}'..."
            docker-compose down --remove-orphans 2>/dev/null
            echo "Deleting image '${IMAGE_REPO}:${IMAGE_TAG}'..."
            docker rmi "${IMAGE_REPO}:${IMAGE_TAG}"
            if [ $? -eq 0 ]; then
                echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' deleted successfully."
            else
                echo "Error deleting image. It might be in use by a stopped container not managed by this compose file or a child image."
            fi
        else
            echo "Image deletion cancelled."
        fi
    else
        echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' not found."
    fi
}

print_help() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Management script for the '${CONTAINER_NAME}' development environment."
    echo ""
    echo "Commands:"
    echo "  start         - Start the development environment container."
    echo "  stop          - Stop the development environment container."
    echo "  rm            - Stop and remove the development environment container."
    echo "  status        - Show status of the container."
    echo "  logs          - Tail logs of the container."
    echo "  ssh           - SSH into the running container (ssh ${SSH_USER}@localhost -p ${SSH_PORT})."
    echo "  exec          - Execute a bash shell in the running container using docker-compose exec."
    echo "  rmi           - Remove the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'."
    echo "  help          - Show this help message."
    echo ""
    echo "Before starting, ensure the image is built with ./1-build.sh"
    echo "Environment configuration is loaded from '${ENV_FILE}'."
}

# --- Main Command Logic ---
COMMAND=$1
shift || true

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
    ssh)
        ssh_into_container
        ;;
    exec)
        exec_into_container "$@"
        ;;
    rmi)
        remove_image
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