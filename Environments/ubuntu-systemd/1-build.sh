#!/bin/bash
set -e

# --- Configuration ---
# Get script's directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Get project root directory
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# Switch to project root directory
cd "$PROJECT_ROOT" || exit 1

# Source environment variables from .env file for the current dev image (ubuntu-systemd)
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env for dev image (ubuntu-systemd)"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found. Using default script values for dev image (ubuntu-systemd)."
    SYSTEMD_UBUNTU_CONTAINER_NAME="shuai-ubuntu-systemd"
    SYSTEMD_UBUNTU_IMAGE_REPO="shuai/ubuntu-systemd"
    SYSTEMD_UBUNTU_IMAGE_TAG="latest"
fi

# Define base image directory and its build script (relative to project root)
BASE_IMAGE_BUILD_SCRIPT_REL_PATH="Environments/ubuntu-base-systemd/1-build.sh"
# Define base image name and tag (must match what base image build script produces and this Dockerfile uses)
# These should ideally align with Environments/ubuntu-base-systemd/.env
BASE_IMAGE_REPO="shuai/ubuntu-base-systemd"
BASE_IMAGE_TAG="latest"
BASE_IMAGE_FULL="${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG}"

# Define dev image name/tag using sourced/default variables for this environment
DEV_IMAGE_NAME="${SYSTEMD_UBUNTU_IMAGE_REPO}"
DEV_IMAGE_TAG="${SYSTEMD_UBUNTU_IMAGE_TAG}"
DEV_IMAGE_FULL="${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}"
DEV_CONTAINER_NAME="${SYSTEMD_UBUNTU_CONTAINER_NAME}"

# Compose file for cleaning up the dev container (relative to project root)
DEV_COMPOSE_FILE_REL_PATH="Environments/ubuntu-systemd/docker-compose.yaml"

# --- Build Base Image --- #
echo "========== Ensuring Base Image: ${BASE_IMAGE_FULL} =========="
if [ -f "${PROJECT_ROOT}/${BASE_IMAGE_BUILD_SCRIPT_REL_PATH}" ]; then
    echo "Executing base image build script: ${BASE_IMAGE_BUILD_SCRIPT_REL_PATH}"
    # The base build script is expected to run from PROJECT_ROOT and use its own .env
    "${PROJECT_ROOT}/${BASE_IMAGE_BUILD_SCRIPT_REL_PATH}"
    echo "Base image build script execution finished."
else
    echo "Warning: Base image build script not found at ${PROJECT_ROOT}/${BASE_IMAGE_BUILD_SCRIPT_REL_PATH}."
    echo "Assuming base image ${BASE_IMAGE_FULL} already exists or will be pulled."
fi
# Verify base image exists after attempting build/pull
if ! docker image inspect "${BASE_IMAGE_FULL}" &> /dev/null; then
    echo "Error: Base image ${BASE_IMAGE_FULL} not found after build attempt. Cannot proceed."
    exit 1
fi
echo "Base image ${BASE_IMAGE_FULL} is available."
echo ""

# --- Build Development Image --- #
# Already in PROJECT_ROOT

echo "========== Building Ubuntu (Systemd) Development Environment: ${DEV_IMAGE_FULL} =========="
echo "Using base image: ${BASE_IMAGE_FULL}" # This FROM directive is in the Dockerfile

# Set environment variables for build
export DOCKER_BUILDKIT=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# Stop and remove existing dev container if it exists using docker-compose down
if docker ps -a --format '{{.Names}}' | grep -q "^${DEV_CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container ${DEV_CONTAINER_NAME} using ${DEV_COMPOSE_FILE_REL_PATH}..."
    docker-compose -f "${DEV_COMPOSE_FILE_REL_PATH}" down --remove-orphans || echo "'docker-compose down' for ${DEV_CONTAINER_NAME} failed, continuing build..."
fi

# Build the dev image using direct docker build
echo "Starting dev image build process using docker build..."

BUILD_ARGS="--build-arg SETUP_MODE=systemd"

# Define Dockerfile path relative to project root for the development image
DOCKERFILE_PATH="Environments/ubuntu-systemd/Dockerfile"

# Execute docker build from project root (context is current directory: .)
echo "Building ${DEV_IMAGE_FULL} from ${DOCKERFILE_PATH} with context $PROJECT_ROOT..."
if docker build ${BUILD_ARGS} -f "${DOCKERFILE_PATH}" -t "${DEV_IMAGE_FULL}" . ; then
    echo "========== Build Complete =========="
    echo "Development image ${DEV_IMAGE_FULL} built successfully."
    echo "To start the container, navigate to $SCRIPT_DIR and run: ./2-dev-cli.sh start"
else
    echo "Build failed for development image ${DEV_IMAGE_FULL} using docker build."
    exit 1
fi 