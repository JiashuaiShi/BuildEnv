#!/bin/bash
# Script to build the Docker image for the biocontainers-dev component

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"

# Load environment variables from .env file in the component directory
ENV_FILE="${SCRIPT_DIR}/.env"
if [ -f "${ENV_FILE}" ]; then
    echo "Loading environment variables from ${ENV_FILE}"
    # Export them so docker-compose can use them for variable substitution and build args
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: ${ENV_FILE} not found. Build might use default values or fail."
fi

# Image name from .env or default
IMAGE_REPO=${BIO_BIOCONTAINERS_IMAGE_REPO:-my-repo/biocontainers-dev}
IMAGE_TAG=${BIO_BIOCONTAINERS_IMAGE_TAG:-latest}
FULL_IMAGE_NAME="${IMAGE_REPO}:${IMAGE_TAG}"
SERVICE_NAME="biocontainers-dev" # Service name in docker-compose.yaml

# Build-time proxy arguments for docker-compose build
# These will be passed to 'args' in docker-compose.yaml if set in the current shell
# The docker-compose.yaml itself references these (e.g., http_proxy: "${http_proxy}")
# So they are primarily controlled by being set in the shell running this script.

# Ensure necessary variables for unified-common-setup.sh are set (from .env or defaults)
# These are used by docker-compose.yaml build.args
: "${SSH_USER_NAME:?SSH_USER_NAME not set or empty, please define in .env or export}"
: "${USER_PASSWORD:?USER_PASSWORD not set or empty, please define in .env or export}"

echo "Building image for service: ${SERVICE_NAME}"
echo "Target image name: ${FULL_IMAGE_NAME}"

# Pass proxy settings from current environment to docker-compose build
# The docker-compose.yaml file is set up to receive these as build args.
# No need to explicitly construct --build-arg for docker-compose if args are in compose file.

# Navigate to the component directory for docker-compose context
cd "${SCRIPT_DIR}" || exit 1

# Use docker-compose build. It will use variables from the environment (exported from .env)
# and from the 'args' section in docker-compose.yaml.
docker-compose build --no-cache ${SERVICE_NAME}

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built image for service ${SERVICE_NAME} -> ${FULL_IMAGE_NAME}"
    echo "You can also tag it as latest if needed:"
    echo "  docker tag ${FULL_IMAGE_NAME} ${IMAGE_REPO}:latest"
else
    echo "Error building image for service ${SERVICE_NAME}."
    exit 1
fi 