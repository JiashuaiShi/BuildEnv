#!/bin/bash
# CLI for managing the conda-bio-pkgs toolkit container and image

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# Load .env file from the component directory
if [ -f "${ENV_FILE}" ]; then
    # echo "Loading environment variables from ${ENV_FILE}"
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: Environment file '${ENV_FILE}' not found."
fi

# Configuration (these should be defined in .env)
IMAGE_REPO=${BIO_CONDABIOPKGS_IMAGE_REPO:-my-repo/conda-bio-pkgs}
IMAGE_TAG=${BIO_CONDABIOPKGS_IMAGE_TAG:-latest}
CONTAINER_NAME=${BIO_CONDABIOPKGS_CONTAINER_NAME:-conda-bio-pkgs-tools}
SERVICE_NAME="conda-bio-pkgs" # Service name in docker-compose.yaml

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
    echo "Starting container '${CONTAINER_NAME}' for service '${SERVICE_NAME}'..."
    # The docker-compose.yaml is configured with 'command: ["tail", "-f", "/dev/null"]'
    # to keep the container running for exec.
    docker-compose up -d ${SERVICE_NAME}
    echo "Container should be up. Use './2-dev-cli.sh status' to check."
}

stop_container() {
    echo "Stopping container '${CONTAINER_NAME}' for service '${SERVICE_NAME}'..."
    docker-compose stop ${SERVICE_NAME}
    echo "To remove the stopped container, use 'docker-compose rm -f ${SERVICE_NAME}'"
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

exec_into_container() {
    check_image
    echo "Executing command in a new container from image '${IMAGE_REPO}:${IMAGE_TAG}' (or existing if started)."
    echo "If you want to run a command in the long-running service container (if started with ./2-dev-cli.sh start),"
    echo "  use: docker-compose exec ${SERVICE_NAME} <your_command>"
    echo "Example for running a tool directly (transient container):"
    echo "  ./2-dev-cli.sh run <tool_command> [args...]"
    echo "Opening a bash shell in a new, transient container..."
    # This runs a new container based on the service definition in docker-compose.yaml
    # It will inherit volumes, environment, etc.
    docker-compose run --rm ${SERVICE_NAME} bash
}

run_tool_in_container() {
    check_image
    if [ -z "$1" ]; then
        echo "Usage: $0 run <tool_command> [args...]"
        echo "Example: $0 run bwa index ref.fasta"
        exit 1
    fi
    echo "Running command in a new transient container: $@"
    # docker-compose run will use the service definition (volumes, env vars) from docker-compose.yaml
    docker-compose run --rm ${SERVICE_NAME} "$@"
}

remove_image() {
    if docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        read -p "Are you sure you want to delete the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'? (y/n): " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
            echo "Attempting to stop and remove any containers using this image..."
            # Stop/remove containers associated with the service in docker-compose.yaml
            docker-compose down --remove-orphans 2>/dev/null
            # General check for other containers based on the image name (more aggressive)
            # running_containers=$(docker ps -q --filter ancestor="${IMAGE_REPO}:${IMAGE_TAG}")
            # if [ -n "${running_containers}" ]; then
            #     echo "Stopping containers: ${running_containers}"
            #     docker stop ${running_containers} >/dev/null
            #     echo "Removing containers: ${running_containers}"
            #     docker rm ${running_containers} >/dev/null
            # fi
            echo "Deleting image '${IMAGE_REPO}:${IMAGE_TAG}'..."
            docker rmi "${IMAGE_REPO}:${IMAGE_TAG}"
            if [ $? -eq 0 ]; then
                echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' deleted successfully."
            else
                echo "Error deleting image. It might be in use by a stopped container or a child image."
                echo "Try: docker ps -a | grep ${IMAGE_REPO}"
            fi
        else
            echo "Image deletion cancelled."
        fi
    else
        echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' not found."
    fi
}

print_help() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Management script for the '${CONTAINER_NAME}' toolkit."
    echo ""
    echo "Commands:"
    echo "  start         - Start the toolkit service container (runs 'tail -f /dev/null' to keep alive for exec)."
    echo "  stop          - Stop the toolkit service container."
    echo "  rm            - Stop and remove the toolkit service container."
    echo "  status        - Show status of the toolkit service container."
    echo "  logs          - Tail logs of the toolkit service container."
    echo "  exec          - Open an interactive bash shell in a new, transient container based on the service definition."
    echo "                (For exec into a running 'start'ed container, use 'docker-compose exec ${SERVICE_NAME} bash')"
    echo "  run <cmd...>  - Run a specific command/tool in a new, transient container (e.g., './2-dev-cli.sh run bwa mem ref.fa read1.fq')."
    echo "  rmi           - Remove the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'."
    echo "  help          - Show this help message."
    echo ""
    echo "Before running most commands, ensure the image is built with ./1-build.sh"
    echo "Environment configuration is loaded from '${ENV_FILE}'."
}

# --- Main Command Logic ---
COMMAND=$1
shift || true # Shift even if no arguments to prevent error

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
        exec_into_container "$@"
        ;;
    run)
        run_tool_in_container "$@"
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