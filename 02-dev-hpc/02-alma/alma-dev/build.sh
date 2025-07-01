#!/bin/bash
set -e # Exit on any error

# --- Configuration ---
BASE_DIR="../base"
BASE_IMAGE_NAME="alma-base"
BASE_IMAGE_TAG="latest"
DEV_IMAGE_NAME="alma-dev"
DEV_IMAGE_TAG="latest"
ENV_FILE=".env"

# --- Helper Functions ---
info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
    exit 1
}

# --- Main Logic ---
info "Starting build for the AlmaLinux HPC Development Environment..."

# 1. Check for Docker
if ! command -v docker &> /dev/null; then
    error "Docker could not be found. Please install Docker."
fi

# 2. Build the base image if it doesn't exist
if ! docker image inspect "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" &> /dev/null; then
    info "Base image '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' not found. Building it now..."
    if [ ! -f "${BASE_DIR}/Dockerfile" ]; then
        error "Base Dockerfile not found at '${BASE_DIR}/Dockerfile'"
    fi

    # Load password from .env file
    if [ -f "$ENV_FILE" ]; then
        export $(grep -v '^#' $ENV_FILE | xargs)
    else
        error "'.env' file not found. Please create it with a DEV_PASSWORD."
    fi

    if [ -z "$DEV_PASSWORD" ]; then
        error "DEV_PASSWORD is not set in the .env file."
    fi

    # Build the base image with the password as a build-arg
    docker build \
        --build-arg "DEV_PASSWORD=${DEV_PASSWORD}" \
        -t "${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}" \
        "${BASE_DIR}"
    info "Base image built successfully."
else
    info "Base image '${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}' already exists. Skipping build."
fi

# 3. Build the development image using Docker Compose
info "Building the development image '${DEV_IMAGE_NAME}:${DEV_IMAGE_TAG}'..."
# Docker Compose will use the docker-compose.yaml in the current directory
if docker-compose build; then
    info "========== Build Complete =========="
    info "To start the container, run: ./start.sh"
    info "To connect via SSH, run: ./dev-cli.sh ssh"
else
    error "Development image build failed."
fi