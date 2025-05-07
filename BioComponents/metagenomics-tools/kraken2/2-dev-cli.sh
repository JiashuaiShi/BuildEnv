#!/bin/bash
# CLI for managing the kraken2 tool (part of metagenomics-tools)

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
IMAGE_REPO=${BIO_METAGENOMICS_KRAKEN2_IMAGE_REPO:-my-repo/kraken2-tool}
IMAGE_TAG=${BIO_METAGENOMICS_KRAKEN2_IMAGE_TAG:-2.1.3}
SERVICE_NAME="kraken2" # Service name in this component's docker-compose.yaml

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
run_tool() {
    check_image
    if [ -z "$1" ]; then
        echo "Usage: $0 run <kraken2_command_and_args>"
        echo "Example: $0 run --db /path/to/db --threads 4 input.fastq"
        echo "Note: Mount volumes via docker-compose.yaml or use the top-level metagenomics-tools CLI for orchestrated runs."
        echo "Running kraken2 --help as an example:"
        docker-compose run --rm ${SERVICE_NAME} --help
        exit 0
    fi
    echo "Running kraken2 command in a new transient container: $@"
    # docker-compose run will use the service definition from this component's docker-compose.yaml
    # Volumes need to be pre-configured in the docker-compose.yaml or added via -v to the run command if not.
    # For simplicity here, assuming docker-compose.yaml in this dir is minimal or used for build mostly.
    # For complex runs with data, the top-level CLI is preferred.
    docker-compose run --rm ${SERVICE_NAME} "$@"
}

exec_shell() {
    check_image
    echo "Opening a bash shell in a new, transient container for '${SERVICE_NAME}'..."
    # This runs a new container based on the service definition in this component's docker-compose.yaml
    docker-compose run --rm ${SERVICE_NAME} bash
}

remove_image_cmd() {
    if docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        read -p "Are you sure you want to delete the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'? (y/n): " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
            echo "Deleting image '${IMAGE_REPO}:${IMAGE_TAG}'..."
            docker rmi "${IMAGE_REPO}:${IMAGE_TAG}"
            # Note: This won't remove containers if any were started and kept outside of 'run --rm'
        else
            echo "Image deletion cancelled."
        fi
    else
        echo "Image '${IMAGE_REPO}:${IMAGE_TAG}' not found."
    fi
}

print_help() {
    echo "Usage: $0 <command> [options]"
    echo "CLI for the kraken2 tool component."
    echo "Commands:
      run <args>    Run kraken2 with specified arguments in a new container.
                    (e.g., ./2-dev-cli.sh run --help)
      exec          Open an interactive bash shell in a new container.
      rmi           Remove the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'.
      help          Show this help message."
    echo "Build the image first with ./1-build.sh."
}

# --- Main Command Logic ---
COMMAND=$1
shift || true

case "${COMMAND}" in
    run)
        run_tool "$@"
        ;;
    exec)
        exec_shell
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