#!/bin/bash
# Script to build the Docker image for the krona component

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
IMAGE_REPO=${BIO_METAGENOMICS_KRONA_IMAGE_REPO:-my-repo/krona-tool}
IMAGE_TAG=${BIO_METAGENOMICS_KRONA_IMAGE_TAG:-2.8.1}
FULL_IMAGE_NAME="${IMAGE_REPO}:${IMAGE_TAG}"
SERVICE_NAME="krona" # Service name in this component's docker-compose.yaml

echo "Building image for service: ${SERVICE_NAME}"
echo "Target image name: ${FULL_IMAGE_NAME}"

# Navigate to this component's directory for docker-compose context
cd "${SCRIPT_DIR}" || exit 1

# Use docker-compose build. It will use variables from the environment (exported from .env)
# and from the 'args' section in this component's docker-compose.yaml.
# Proxy variables (http_proxy, etc.) if set in the current shell will be passed to build args.
docker-compose build --no-cache ${SERVICE_NAME}

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built image for service ${SERVICE_NAME} -> ${FULL_IMAGE_NAME}"
else
    echo "Error building image for service ${SERVICE_NAME}."
    exit 1
fi 