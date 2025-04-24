#!/bin/bash
set -e

# --- Configuration ---
# Get script's directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Define base image directory relative to this script
BASE_DIR=$(realpath "$SCRIPT_DIR/../ubuntu-base")
# Define base image name and tag
BASE_IMAGE_NAME="shuai/ubuntu-base-systemd"
BASE_IMAGE_TAG="latest"
BASE_IMAGE_FULL="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

# Define dev image name/tag (should match docker-compose.yaml)
DEV_IMAGE_NAME="shuai/ubuntu-dev"
DEV_IMAGE_TAG="1.0"
DEV_IMAGE_FULL="${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}"
DEV_CONTAINER_NAME="shuai-ubuntu-dev"

# --- Desired User/Group Configuration --- #
DESIRED_USER_NAME="shijiashuai"
DESIRED_UID=2034
DESIRED_GID=2000
# Optional: Define desired password here if needed, otherwise Dockerfile default is used
# DESIRED_PASSWORD="new_password"

# --- Build Base Image --- #
echo "========== Building Base Image: ${BASE_IMAGE_FULL} =========="
echo "Using Dockerfile from: ${BASE_DIR}"
# Use docker build directly for the base image
if docker build -t "${BASE_IMAGE_FULL}" "${BASE_DIR}"; then
    echo "Base image ${BASE_IMAGE_FULL} built successfully."
else
    echo "Failed to build base image ${BASE_IMAGE_FULL}."
    exit 1
fi
echo ""

# --- Build Development Image --- #
# Change to the dev environment directory for docker-compose
cd "$SCRIPT_DIR" || exit 1

echo "========== Building Ubuntu Development Environment: ${DEV_IMAGE_FULL} =========="
echo "Using base image: ${BASE_IMAGE_FULL}"

# Set environment variables for docker-compose build
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# Stop and remove existing dev container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${DEV_CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container ${DEV_CONTAINER_NAME}..."
    # Use docker-compose down in the current directory
    docker-compose down --remove-orphans || echo "'docker-compose down' failed, continuing build..."
fi

# Build the dev image using docker-compose
echo "Starting dev image build process using docker-compose..."
# Pass the desired UID/GID/etc. as build arguments
echo "Passing build args: USER_NAME=${DESIRED_USER_NAME}, USER_UID=${DESIRED_UID}, USER_GID=${DESIRED_GID}"
# Add more --build-arg flags if passing password, etc.
if docker-compose build --build-arg USER_NAME=${DESIRED_USER_NAME} --build-arg USER_UID=${DESIRED_UID} --build-arg USER_GID=${DESIRED_GID}; then
    echo "========== Build Complete =========="
    echo "Development image ${DEV_IMAGE_FULL} built successfully."
    echo "To start the container, run: ./2-dev-cli.sh start"
else
    echo "Build failed for development image ${DEV_IMAGE_FULL}."
    exit 1
fi 