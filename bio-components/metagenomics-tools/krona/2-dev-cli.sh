#!/bin/bash
# CLI for managing the krona tool (part of metagenomics-tools)

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
IMAGE_REPO=${BIO_METAGENOMICS_KRONA_IMAGE_REPO:-my-repo/krona-tool}
IMAGE_TAG=${BIO_METAGENOMICS_KRONA_IMAGE_TAG:-2.8.1}
SERVICE_NAME="krona" # Service name in this component's docker-compose.yaml

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
    # The Dockerfile has ENTRYPOINT ["/usr/local/bin/ktImportTaxonomy"]
    # The docker-compose.yaml has command: ktImportTaxonomy, which becomes the default arg to entrypoint if no other args given.
    # If user types './2-dev-cli.sh run foo.txt -o bar.html', then "foo.txt -o bar.html" is passed to entrypoint.
    if [ -z "$1" ]; then
        echo "Usage: $0 run <ktImportTaxonomy_arguments>"
        echo "Example: $0 run input.taxonomy -o output.krona.html"
        echo "Running ktImportTaxonomy with no arguments (will show its help):"
        docker-compose run --rm ${SERVICE_NAME}
        exit 0
    fi
    echo "Running ktImportTaxonomy with arguments in a new transient container: $@"
    docker-compose run --rm ${SERVICE_NAME} "$@"
}

exec_shell() {
    check_image
    echo "Opening a bash shell in a new, transient container for '${SERVICE_NAME}'..."
    # Override entrypoint to get a shell
    docker-compose run --rm --entrypoint bash ${SERVICE_NAME}
}

remove_image_cmd() {
    if docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" &> /dev/null; then
        read -p "Are you sure you want to delete the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'? (y/n): " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
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
    echo "CLI for the krona tool component (ktImportTaxonomy)."
    echo "Commands:
      run <args>    Run ktImportTaxonomy with specified arguments.
                    (e.g., ./2-dev-cli.sh run input.txt -o output.html)
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