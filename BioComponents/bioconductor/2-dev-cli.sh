#!/bin/bash
# CLI for managing the bioconductor-dev development environment

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# Load .env file
if [ -f "${ENV_FILE}" ]; then
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: Environment file '${ENV_FILE}' not found."
fi

# Configuration (from .env or defaults)
IMAGE_REPO=${BIO_BIOCONDUCTOR_IMAGE_REPO:-my-repo/bioconductor-dev}
IMAGE_TAG=${BIO_BIOCONDUCTOR_IMAGE_TAG:-latest}
CONTAINER_NAME=${BIO_BIOCONDUCTOR_CONTAINER_NAME:-bioconductor-dev-env}
SERVICE_NAME="bioconductor-dev"
SSH_PORT=${BIO_BIOCONDUCTOR_SSH_PORT:-2204}
SSH_USER=${SSH_USER_NAME:-shijiashuai}
# RSTUDIO_PORT=${BIO_BIOCONDUCTOR_RSTUDIO_PORT:-8787} # If RStudio is used

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
    # if RStudio is active: echo "RStudio access: http://localhost:${RSTUDIO_PORT}"
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
    ssh "${SSH_USER}@localhost" -p "${SSH_PORT}"
}

exec_into_container() {
    echo "Opening a bash shell in running container '${CONTAINER_NAME}' as user '${SSH_USER}'..."
    docker-compose exec -u "${SSH_USER}" ${SERVICE_NAME} bash
}

remove_image() {
    if docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        read -p "Are you sure you want to delete image '${IMAGE_REPO}:${IMAGE_TAG}'? (y/n): " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
            docker-compose down --remove-orphans 2>/dev/null
            docker rmi "${IMAGE_REPO}:${IMAGE_TAG}"
            echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' deleted."
        else
            echo "Image deletion cancelled."
        fi
    else
        echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' not found."
    fi
}

print_help() {
    echo "Usage: $0 <command>"
    echo "Manages the '${CONTAINER_NAME}' Bioconductor development environment."
    echo "Commands:
      start         Start the container.
      stop          Stop the container.
      rm            Stop and remove the container.
      status        Show container status.
      logs          Tail container logs.
      ssh           SSH into the container (ssh ${SSH_USER}@localhost -p ${SSH_PORT}).
      exec          Open a bash shell using docker-compose exec.
      rmi           Remove the Docker image.
      help          Show this help message."
    # if RStudio is active: echo "  rstudio_url   Show RStudio URL (http://localhost:${RSTUDIO_PORT})"
}

# RStudio_url() { # Example if RStudio is used
#     echo "RStudio URL: http://localhost:${RSTUDIO_PORT}"
# }

COMMAND=$1
shift || true

case "${COMMAND}" in
    start) start_container ;;    stop) stop_container ;;    rm) remove_container ;;
    status) show_status ;;      logs) show_logs ;;         ssh) ssh_into_container ;;
    exec) exec_into_container "$@" ;; rmi) remove_image ;;   help|--help|-h) print_help ;;
    # rstudio_url) RStudio_url ;; # Example if RStudio is used
    *) echo "Error: Unknown command '${COMMAND}'."; print_help; exit 1 ;;
esac
exit 0 