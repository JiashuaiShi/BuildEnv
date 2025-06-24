#!/bin/bash
# Lightweight wrapper script for the 'dev-cpp-python' environment.

# This script delegates all commands to the centralized management script.

set -e

# The directory of this script, which is the environment's root directory.
ENV_DIR=$(dirname "$(realpath "$0")")

# The location of the centralized management script.
MANAGE_SCRIPT_PATH="$ENV_DIR/../../build-logic/scripts/manage-env.sh"

# Check if the management script exists
if [ ! -f "$MANAGE_SCRIPT_PATH" ]; then
    echo "Error: Central management script not found at '$MANAGE_SCRIPT_PATH'"
    exit 1
fi

# Call the central script, passing the environment directory and all other arguments.
bash "$MANAGE_SCRIPT_PATH" "$ENV_DIR" "$@"
