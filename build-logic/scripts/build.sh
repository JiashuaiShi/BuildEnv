#!/bin/bash
# Centralized build script for the Environment-as-Code framework

set -e

# Check if an environment name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <app-environment-name>"
    echo "Example: $0 dev-cpp-python"
    exit 1
fi

APP_ENV_NAME=$1
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../../")
APP_ENV_DIR="$ROOT_DIR/env-dev/app/$APP_ENV_NAME"

# Check if the app environment directory exists
if [ ! -d "$APP_ENV_DIR" ]; then
    echo "Error: Application environment '$APP_ENV_NAME' not found at '$APP_ENV_DIR'."
    exit 1
fi

# Load environment variables to find dependencies
source "$APP_ENV_DIR/.env"

# Define layer paths
BASE_LAYER_DIR="$ROOT_DIR/env-dev/base/$BASE_IMAGE_NAME"
VARIANT_LAYER_DIR="$ROOT_DIR/env-dev/variant/$VARIANT_IMAGE_NAME"

# Build dependency chain in order
echo "Starting build for '$APP_ENV_NAME'..."

# 1. Build Base Layer
if [ -d "$BASE_LAYER_DIR" ] && [ -f "$BASE_LAYER_DIR/docker-compose.yaml" ]; then
    echo "--- Building Base Layer: $BASE_IMAGE_NAME ---"
    docker-compose -f "$BASE_LAYER_DIR/docker-compose.yaml" build
else
    echo "Warning: Base layer '$BASE_IMAGE_NAME' not found or is incomplete. Skipping."
fi

# 2. Build Variant Layer
if [ -d "$VARIANT_LAYER_DIR" ] && [ -f "$VARIANT_LAYER_DIR/docker-compose.yaml" ]; then
    echo "--- Building Variant Layer: $VARIANT_IMAGE_NAME ---"
    docker-compose -f "$VARIANT_LAYER_DIR/docker-compose.yaml" build
else
    echo "Warning: Variant layer '$VARIANT_IMAGE_NAME' not found or is incomplete. Skipping."
fi

# 3. Build Application Layer
echo "--- Building Application Layer: $APP_ENV_NAME ---"
docker-compose -f "$APP_ENV_DIR/docker-compose.yaml" build

echo "Build process for '$APP_ENV_NAME' completed successfully."
