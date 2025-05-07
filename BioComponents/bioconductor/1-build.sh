#!/bin/bash
# Script to build the Docker image for the bioconductor-dev component

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file
ENV_FILE="${SCRIPT_DIR}/.env"
if [ -f "${ENV_FILE}" ]; then
    echo "Loading environment variables from ${ENV_FILE}"
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: ${ENV_FILE} not found. Build might use default values or fail."
fi

# Configuration from .env or defaults
IMAGE_REPO=${BIO_BIOCONDUCTOR_IMAGE_REPO:-my-repo/bioconductor-dev}
IMAGE_TAG=${BIO_BIOCONDUCTOR_IMAGE_TAG:-latest}
FULL_IMAGE_NAME="${IMAGE_REPO}:${IMAGE_TAG}"
SERVICE_NAME="bioconductor-dev" # Service name in docker-compose.yaml

# Ensure necessary variables for setup script are set (from .env or defaults)
: "${SSH_USER_NAME:?SSH_USER_NAME not set or empty, please define in .env or export}"
: "${USER_PASSWORD:?USER_PASSWORD not set or empty, please define in .env or export}"

echo "Building image for service: ${SERVICE_NAME}"
echo "Target image name: ${FULL_IMAGE_NAME}"

# Navigate to the component directory for docker-compose context
cd "${SCRIPT_DIR}" || exit 1

# Use docker-compose build. It uses variables from the environment (exported from .env)
# and from the 'args' section in docker-compose.yaml.
docker-compose build --no-cache ${SERVICE_NAME}

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built image for service ${SERVICE_NAME} -> ${FULL_IMAGE_NAME}"
else
    echo "Error building image for service ${SERVICE_NAME}."
    exit 1
fi 