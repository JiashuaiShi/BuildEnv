#!/bin/bash
# Script to build the ubuntu-base-systemd Docker image

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file in this component's directory
ENV_FILE="${SCRIPT_DIR}/.env"
if [ -f "${ENV_FILE}" ]; then
    echo "Loading environment variables from ${ENV_FILE}"
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: ${ENV_FILE} not found. Build might use default values or fail."
fi

# Image name from .env or default
IMAGE_REPO=${UBUNTU_BASE_SYSTEMD_IMAGE_REPO:-shuai/ubuntu-base-systemd}
IMAGE_TAG=${UBUNTU_BASE_SYSTEMD_IMAGE_TAG:-noble}
FULL_IMAGE_NAME="${IMAGE_REPO}:${IMAGE_TAG}"
# Service name from docker-compose.yaml
SERVICE_NAME="ubuntu-base-systemd"

echo "Building image for service: ${SERVICE_NAME}"
echo "Target image name: ${FULL_IMAGE_NAME}"

# Navigate to this component's directory for docker-compose context
cd "${SCRIPT_DIR}" || exit 1

# Use docker-compose build. 
# It will use variables from the environment (exported from .env) for substitution 
# in docker-compose.yaml and for build args specified in docker-compose.yaml.
# Proxy variables (http_proxy, etc.), if set in the current shell, will be passed to build args.
docker-compose build --no-cache ${SERVICE_NAME}

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built image for service ${SERVICE_NAME} -> ${FULL_IMAGE_NAME}"
else
    echo "Error building image for service ${SERVICE_NAME}."
    exit 1
fi 