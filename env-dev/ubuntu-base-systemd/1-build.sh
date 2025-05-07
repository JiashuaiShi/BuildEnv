#!/bin/bash
set -e

# Get script's directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Get project root directory
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." &> /dev/null && pwd)

# Switch to project root directory to ensure correct build context
cd "$PROJECT_ROOT" || exit 1

# Source environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Sourcing environment variables from $SCRIPT_DIR/.env"
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Warning: $SCRIPT_DIR/.env file not found. Using default script values."
    UBUNTU_BASE_SYSTEMD_IMAGE_REPO="shuai/ubuntu-base-systemd"
    UBUNTU_BASE_SYSTEMD_IMAGE_TAG="latest"
fi

IMAGE_FULL="${UBUNTU_BASE_SYSTEMD_IMAGE_REPO}:${UBUNTU_BASE_SYSTEMD_IMAGE_TAG}"
DOCKERFILE_REL_PATH="Environments/ubuntu-base-systemd/Dockerfile" # Relative to PROJECT_ROOT

echo "========== Building Ubuntu Base Systemd Image: ${IMAGE_FULL} =========="
echo "Project Root: $PROJECT_ROOT"
echo "Dockerfile: $DOCKERFILE_REL_PATH"

# Set common build environment variables
export DOCKER_BUILDKIT=1
export PYTHONUNBUFFERED=1

# Build the image using docker build
# The context is PROJECT_ROOT (.), and -f specifies the Dockerfile path relative to that context.
if docker build -t "${IMAGE_FULL}" -f "${DOCKERFILE_REL_PATH}" . ; then
    echo "========== Build Complete =========="
    echo "Ubuntu Base Systemd Image ${IMAGE_FULL} built successfully."
else
    echo "Failed to build Ubuntu Base Systemd Image ${IMAGE_FULL}."
    exit 1
fi 