#!/bin/bash
# Script to build the Docker image for the conda-bio-pkgs component

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)" # Assuming scripts are two levels down from project root

# Load environment variables from .env file in the component directory
ENV_FILE="${SCRIPT_DIR}/.env"
if [ -f "${ENV_FILE}" ]; then
    echo "Loading environment variables from ${ENV_FILE}"
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: ${ENV_FILE} not found."
fi

# Default image name and tag if not set in .env
IMAGE_REPO=${BIO_CONDABIOPKGS_IMAGE_REPO:-my-repo/conda-bio-pkgs}
IMAGE_TAG=${BIO_CONDABIOPKGS_IMAGE_TAG:-latest}
FULL_IMAGE_NAME="${IMAGE_REPO}:${IMAGE_TAG}"

# Build-time arguments (e.g., proxies)
# Users should set these in their shell environment if needed, e.g., export HTTP_PROXY=...
BUILD_ARGS=""
if [ -n "${HTTP_PROXY}" ]; then
    BUILD_ARGS="${BUILD_ARGS} --build-arg HTTP_PROXY=${HTTP_PROXY}"
fi
if [ -n "${HTTPS_PROXY}" ]; then
    BUILD_ARGS="${BUILD_ARGS} --build-arg HTTPS_PROXY=${HTTPS_PROXY}"
fi
if [ -n "${NO_PROXY}" ]; then
    BUILD_ARGS="${BUILD_ARGS} --build-arg NO_PROXY=${NO_PROXY}"
fi
if [ -n "${FTP_PROXY}" ]; then
    BUILD_ARGS="${BUILD_ARGS} --build-arg FTP_PROXY=${FTP_PROXY}"
fi

echo "Building image: ${FULL_IMAGE_NAME}"
echo "Build context: ${SCRIPT_DIR}"
echo "Dockerfile: ${SCRIPT_DIR}/Dockerfile"
echo "Build arguments: ${BUILD_ARGS}"

# Navigate to the component directory to ensure correct context for docker-compose
cd "${SCRIPT_DIR}" || exit 1

# Option 1: Using docker-compose build (preferred if docker-compose.yaml is well-defined for build)
# This will use the 'build' section in docker-compose.yaml
# Ensure your docker-compose.yaml's build section correctly points to the Dockerfile
# and specifies any necessary args.
docker-compose build --no-cache ${BUILD_ARGS} conda-bio-pkgs # 'conda-bio-pkgs' is the service name

# Option 2: Using docker build directly (if docker-compose.yaml is not used for building)
# docker build --no-cache -t "${FULL_IMAGE_NAME}" ${BUILD_ARGS} -f Dockerfile .

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built image: ${FULL_IMAGE_NAME}"
    echo "You can also tag it as latest if needed:"
    echo "  docker tag ${FULL_IMAGE_NAME} ${IMAGE_REPO}:latest"
else
    echo "Error building image: ${FULL_IMAGE_NAME}"
    exit 1
fi

# Return to the original directory (optional, good practice)
# cd - > /dev/null 