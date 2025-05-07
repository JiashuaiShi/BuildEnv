#!/bin/bash
# CLI for managing the R-analysis tool (part of metagenomics-tools)

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
IMAGE_REPO=${BIO_METAGENOMICS_RANALYSIS_IMAGE_REPO:-my-repo/r-analysis-tool}
IMAGE_TAG=${BIO_METAGENOMICS_RANALYSIS_IMAGE_TAG:-latest}
SERVICE_NAME="r-analysis" # Service name in this component's docker-compose.yaml

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
run_r_script() {
    check_image
    if [ -z "$1" ]; then
        echo "Usage: $0 run <R_script_path_in_container> [script_arguments...]"
        echo "Example: $0 run /scripts/diversity_analysis.R --input /data/otu_table.txt --output /data/diversity_results.txt"
        echo "Note: Scripts from the local './scripts' directory are mounted to '/scripts' in the container by default."
        echo "       Data from local './data' is mounted to '/data'."
        exit 1
    fi
    echo "Running Rscript in a new transient container: $@"
    # The Dockerfile has ENTRYPOINT ["Rscript"], so $@ are passed as arguments to Rscript
    docker-compose run --rm ${SERVICE_NAME} "$@"
}

open_r_shell() {
    check_image
    echo "Opening an interactive R shell in a new, transient container for '${SERVICE_NAME}'..."
    docker-compose run --rm --entrypoint R ${SERVICE_NAME}
}

open_bash_shell() {
    check_image
    echo "Opening a bash shell in a new, transient container for '${SERVICE_NAME}'..."
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
    echo "CLI for the R-analysis tool component."
    echo "Commands:
      run <script> [args...]  Run an R script (e.g., /scripts/script.R) with arguments.
      r_shell                 Open an interactive R console.
      bash                    Open an interactive bash shell.
      rmi                     Remove the Docker image '${IMAGE_REPO}:${IMAGE_TAG}'.
      help                    Show this help message."
    echo "Build the image first with ./1-build.sh."
    echo "Local './scripts' is mounted to '/scripts', local './data' to '/data' in container when using 'run'."
}

# --- Main Command Logic ---
COMMAND=$1
shift || true

case "${COMMAND}" in
    run)
        run_r_script "$@"
        ;;
    r_shell|R)
        open_r_shell
        ;;
    bash|shell)
        open_bash_shell
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