#!/bin/bash
set -e

# --- Configuration ---
# Get script's directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Get project root directory
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# Switch to project root directory
cd "$PROJECT_ROOT" || exit 1

# Source environment variables from .env file for the dev image
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env for dev image"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found. Using default script values for dev image."
    SYSTEMD_UBUNTU_CONTAINER_NAME="shuai-ubuntu-systemd"
    SYSTEMD_UBUNTU_IMAGE_REPO="shuai/ubuntu-systemd"
    SYSTEMD_UBUNTU_IMAGE_TAG="latest"
fi

# Define base image directory relative to project root
BASE_DIR_REL="Environments/ubuntu-base" # Path relative to PROJECT_ROOT
BASE_DIR_ABS="$PROJECT_ROOT/$BASE_DIR_REL"
# Define base image name and tag
BASE_IMAGE_NAME="shuai/ubuntu-base-systemd"
BASE_IMAGE_TAG="latest" # Or make this configurable via an .env in base or root .env
BASE_IMAGE_FULL="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

# Define dev image name/tag using sourced/default variables
DEV_IMAGE_NAME="${SYSTEMD_UBUNTU_IMAGE_REPO}"
DEV_IMAGE_TAG="${SYSTEMD_UBUNTU_IMAGE_TAG}"
DEV_IMAGE_FULL="${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}"
DEV_CONTAINER_NAME="${SYSTEMD_UBUNTU_CONTAINER_NAME}"

# Compose file for cleaning up the dev container (relative to project root)
DEV_COMPOSE_FILE_REL_PATH="Environments/ubuntu-systemd/docker-compose.yaml"

# --- Build Base Image --- #
echo "========== Building Base Image: ${BASE_IMAGE_FULL} =========="
if [ -d "${BASE_DIR_ABS}" ] && [ -f "${BASE_DIR_ABS}/Dockerfile" ]; then
    echo "Using Dockerfile from: ${BASE_DIR_ABS}"
    # Use docker build directly for the base image. Context is BASE_DIR_REL relative to current dir (PROJECT_ROOT)
    if docker build -t "${BASE_IMAGE_FULL}" "${BASE_DIR_REL}"; then
        echo "Base image ${BASE_IMAGE_FULL} built successfully."
    else
        echo "Failed to build base image ${BASE_IMAGE_FULL}."
        exit 1
    fi
else
    echo "Warning: Base image Dockerfile not found at ${BASE_DIR_ABS}/Dockerfile. Skipping base image build."
    echo "Assuming base image ${BASE_IMAGE_FULL} already exists."
fi
echo ""

# --- Build Development Image --- #
# Already in PROJECT_ROOT

echo "========== Building Ubuntu (Systemd) Development Environment: ${DEV_IMAGE_FULL} =========="
echo "Using base image: ${BASE_IMAGE_FULL}"

# Set environment variables for build
export DOCKER_BUILDKIT=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# Stop and remove existing dev container if it exists using docker-compose down
if docker ps -a --format '{{.Names}}' | grep -q "^${DEV_CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container ${DEV_CONTAINER_NAME} using ${DEV_COMPOSE_FILE_REL_PATH}..."
    # docker-compose -f ... down needs to be run from PROJECT_ROOT
    docker-compose -f "${DEV_COMPOSE_FILE_REL_PATH}" down --remove-orphans || echo "'docker-compose down' for ${DEV_CONTAINER_NAME} failed, continuing build..."
fi

# Build the dev image using direct docker build
echo "Starting dev image build process using docker build..."

BUILD_ARGS="--build-arg SETUP_MODE=systemd"
# Add other build args if Dockerfile expects them and they are not passed via docker-compose.yaml build args
# For example, if unified-common-setup.sh needs USER_NAME, etc., and those are ARGs in Dockerfile:
# BUILD_ARGS+=" --build-arg USER_NAME=${SYSTEMD_UBUNTU_SSH_USER}" # Ensure SYSTEMD_UBUNTU_SSH_USER is in .env

# Define Dockerfile path relative to project root
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