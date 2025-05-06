#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# !! IMPORTANT !!
# This script is designed to be run in parts on DIFFERENT machines.
# Part 1 (source) should be run on the SOURCE machine (e.g., dev-10).
# Part 2 involves manually transferring the exported images to the TARGET machine.
# Part 3 (target) should be run on the TARGET machine (e.g., dev-07).

# --- Common Variables ---
# DATE_TAG=$(date +%Y%m%d) # Uncomment this line to use current date as tag
DATE_TAG="20250506" # Set to the specific tag as requested

BASE_EXPORT_DIR="/data-lush/lush-dev/shijiashuai/baks/dockers"
EXPORT_DIR="${BASE_EXPORT_DIR}/${DATE_TAG}"

# Container and Image Names for AlmaLinux
SOURCE_ALMA_CONTAINER_ID_OR_NAME="e30b9c0d851f" # Or use "shuai-alma-dev" if it's always the name
TARGET_ALMA_IMAGE_REPO="shuai/alma-dev"
TARGET_ALMA_IMAGE_NAME="${TARGET_ALMA_IMAGE_REPO}:${DATE_TAG}"
ALMA_TAR_FILENAME="${TARGET_ALMA_IMAGE_REPO//\//_}_${DATE_TAG}.tar" # Replaces / with _ for filename

# Container and Image Names for Ubuntu
SOURCE_UBUNTU_CONTAINER_ID_OR_NAME="3bd3aec3f3dd" # Or use "shuai-ubuntu-dev" if it's always the name
TARGET_UBUNTU_IMAGE_REPO="shuai/ubuntu-dev"
TARGET_UBUNTU_IMAGE_NAME="${TARGET_UBUNTU_IMAGE_REPO}:${DATE_TAG}"
UBUNTU_TAR_FILENAME="${TARGET_UBUNTU_IMAGE_REPO//\//_}_${DATE_TAG}.tar"

# Target machine new container names and ports
# These might need adjustment based on availability and requirements on the target machine
TARGET_ALMA_NEW_CONTAINER_NAME="shuai-alma-dev-${DATE_TAG}"
# Original alma-dev SSH was 28981 -> 22. Suggesting a new port for target machine.
TARGET_ALMA_SSH_PORT_MAPPING="28991:22" # HostPort:ContainerPort

TARGET_UBUNTU_NEW_CONTAINER_NAME="shuai-ubuntu-dev-${DATE_TAG}"
# Original ubuntu-dev SSH was 28982 -> 22. Suggesting a new port for target machine.
TARGET_UBUNTU_SSH_PORT_MAPPING="28992:22" # HostPort:ContainerPort
# Original ubuntu-dev Netdata was exposed on 28970. Suggesting mapping if needed.
TARGET_UBUNTU_NETDATA_PORT_MAPPING="28971:28970" # HostPort:ContainerPort


# --- Helper Functions ---
info() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

ensure_command_exists() {
    command -v "$1" >/dev/null 2>&1 || error "Required command '$1' is not installed. Please install it and try again."
}

# --- Script Logic ---

run_on_source_host() {
    info "--- Running on SOURCE host (e.g., dev-10) ---"
    ensure_command_exists "docker"

    # 1. Commit running containers to new images
    info "Committing container ${SOURCE_ALMA_CONTAINER_ID_OR_NAME} to image ${TARGET_ALMA_IMAGE_NAME}..."
    if ! docker ps -q --filter "id=${SOURCE_ALMA_CONTAINER_ID_OR_NAME}" --filter "status=running" | grep -q .; then
        error "Container ${SOURCE_ALMA_CONTAINER_ID_OR_NAME} (Alma) is not running or does not exist."
    fi
    docker commit "${SOURCE_ALMA_CONTAINER_ID_OR_NAME}" "${TARGET_ALMA_IMAGE_NAME}"
    info "Successfully committed ${TARGET_ALMA_IMAGE_NAME}"

    info "Committing container ${SOURCE_UBUNTU_CONTAINER_ID_OR_NAME} to image ${TARGET_UBUNTU_IMAGE_NAME}..."
    if ! docker ps -q --filter "id=${SOURCE_UBUNTU_CONTAINER_ID_OR_NAME}" --filter "status=running" | grep -q .; then
        error "Container ${SOURCE_UBUNTU_CONTAINER_ID_OR_NAME} (Ubuntu) is not running or does not exist."
    fi
    docker commit "${SOURCE_UBUNTU_CONTAINER_ID_OR_NAME}" "${TARGET_UBUNTU_IMAGE_NAME}"
    info "Successfully committed ${TARGET_UBUNTU_IMAGE_NAME}"

    # 2. Create export directory if it doesn't exist
    info "Creating export directory: ${EXPORT_DIR}"
    mkdir -p "${EXPORT_DIR}"
    info "Export directory created."

    # 3. Export the new images to tar files
    info "Exporting image ${TARGET_ALMA_IMAGE_NAME} to ${EXPORT_DIR}/${ALMA_TAR_FILENAME}..."
    docker save -o "${EXPORT_DIR}/${ALMA_TAR_FILENAME}" "${TARGET_ALMA_IMAGE_NAME}"
    info "Successfully exported ${TARGET_ALMA_IMAGE_NAME}"

    info "Exporting image ${TARGET_UBUNTU_IMAGE_NAME} to ${EXPORT_DIR}/${UBUNTU_TAR_FILENAME}..."
    docker save -o "${EXPORT_DIR}/${UBUNTU_TAR_FILENAME}" "${TARGET_UBUNTU_IMAGE_NAME}"
    info "Successfully exported ${TARGET_UBUNTU_IMAGE_NAME}"

    info "--- SOURCE host operations complete ---"
    info "Next steps:"
    info "1. Transfer the tar files from ${EXPORT_DIR} on this source host"
    info "   to the same path (${EXPORT_DIR}) on the TARGET host (e.g., dev-07)."
    info "   You can use tools like scp or rsync."
    info "   Example using scp (run from this source host, replace 'user@dev-07' if needed):"
    info "   scp -r \"${EXPORT_DIR}\" user@dev-07:${BASE_EXPORT_DIR}/"
    info "   (Ensure '${BASE_EXPORT_DIR}/' exists on dev-07 or adjust the scp destination path)"
    info "2. Then, run the 'target' part of this script on the TARGET host: ./migrate_containers.sh target"
}

run_on_target_host() {
    info "--- Running on TARGET host (e.g., dev-07) ---"
    ensure_command_exists "docker"

    # 1. Check if export directory and tar files exist
    if [ ! -d "${EXPORT_DIR}" ]; then
        error "Export directory ${EXPORT_DIR} not found. Ensure files were transferred correctly."
    fi
    if [ ! -f "${EXPORT_DIR}/${ALMA_TAR_FILENAME}" ]; then
        error "Alma image tar file not found: ${EXPORT_DIR}/${ALMA_TAR_FILENAME}"
    fi
    if [ ! -f "${EXPORT_DIR}/${UBUNTU_TAR_FILENAME}" ]; then
        error "Ubuntu image tar file not found: ${EXPORT_DIR}/${UBUNTU_TAR_FILENAME}"
    fi

    # 2. Load images from tar files
    info "Loading image ${TARGET_ALMA_IMAGE_NAME} from ${EXPORT_DIR}/${ALMA_TAR_FILENAME}..."
    docker load -i "${EXPORT_DIR}/${ALMA_TAR_FILENAME}"
    info "Successfully loaded ${TARGET_ALMA_IMAGE_NAME}"

    info "Loading image ${TARGET_UBUNTU_IMAGE_NAME} from ${EXPORT_DIR}/${UBUNTU_TAR_FILENAME}..."
    docker load -i "${EXPORT_DIR}/${UBUNTU_TAR_FILENAME}"
    info "Successfully loaded ${TARGET_UBUNTU_IMAGE_NAME}"

    # 3. Run new containers from the loaded images
    # IMPORTANT: Review and adjust container run parameters (ports, volumes, env vars, restart policy, etc.)
    #            to match your requirements and the original container setup.

    info "Attempting to run new Alma container (${TARGET_ALMA_NEW_CONTAINER_NAME}) from image ${TARGET_ALMA_IMAGE_NAME}..."
    info "It will be named: ${TARGET_ALMA_NEW_CONTAINER_NAME}"
    info "SSH will be mapped from host port ${TARGET_ALMA_SSH_PORT_MAPPING%%:*} to container port ${TARGET_ALMA_SSH_PORT_MAPPING#*:}"
    info "Command used for original container was '/usr/bin/supervisor...'. This should be preserved in the committed image."
    # The CMD from the original image (preserved by `docker commit`) will be used.
    # Adding --restart unless-stopped for resilience.
    docker run -d \
        --name "${TARGET_ALMA_NEW_CONTAINER_NAME}" \
        -p "${TARGET_ALMA_SSH_PORT_MAPPING}" \
        --restart unless-stopped \
        "${TARGET_ALMA_IMAGE_NAME}"
        # Add other options like -v for volumes, --env for environment variables if needed, based on original setup.
    info "Alma container ${TARGET_ALMA_NEW_CONTAINER_NAME} start command issued."
    info "Check status with: docker ps -a | grep ${TARGET_ALMA_NEW_CONTAINER_NAME}"

    info "Attempting to run new Ubuntu container (${TARGET_UBUNTU_NEW_CONTAINER_NAME}) from image ${TARGET_UBUNTU_IMAGE_NAME}..."
    info "It will be named: ${TARGET_UBUNTU_NEW_CONTAINER_NAME}"
    info "SSH will be mapped from host port ${TARGET_UBUNTU_SSH_PORT_MAPPING%%:*} to container port ${TARGET_UBUNTU_SSH_PORT_MAPPING#*:}"
    info "Netdata port ${TARGET_UBUNTU_NETDATA_PORT_MAPPING#*:} will be mapped to host port ${TARGET_UBUNTU_NETDATA_PORT_MAPPING%%:*}"
    info "Command used for original container was '/usr/bin/supervisor...'. This should be preserved."
    docker run -d \
        --name "${TARGET_UBUNTU_NEW_CONTAINER_NAME}" \
        -p "${TARGET_UBUNTU_SSH_PORT_MAPPING}" \
        -p "${TARGET_UBUNTU_NETDATA_PORT_MAPPING}" \
        --restart unless-stopped \
        "${TARGET_UBUNTU_IMAGE_NAME}"
        # Add other options as needed.
    info "Ubuntu container ${TARGET_UBUNTU_NEW_CONTAINER_NAME} start command issued."
    info "Check status with: docker ps -a | grep ${TARGET_UBUNTU_NEW_CONTAINER_NAME}"

    info "--- TARGET host operations complete ---"
    info "Verify that the new containers are running correctly (docker ps) and accessible via their new ports."
    info "Remember to configure any necessary firewalls on the target host for the new ports."
}

# --- Main Execution ---
# This script needs to be run with an argument: 'source' or 'target'
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source|target>"
    echo ""
    echo "  source: Run on the SOURCE machine (e.g., dev-10)."
    echo "          Commits specified running containers, and exports them to TAR files in"
    echo "          ${EXPORT_DIR}"
    echo ""
    echo "  target: Run on the TARGET machine (e.g., dev-07)."
    echo "          Loads images from TAR files (expected in ${EXPORT_DIR})"
    echo "          and runs new containers from them."
    echo ""
    echo "Review and potentially adjust variables at the top of the script before running."
    exit 1
fi

if [ "$1" == "source" ]; then
    run_on_source_host
elif [ "$1" == "target" ]; then
    run_on_target_host
else
    error "Invalid argument: '$1'. Use 'source' or 'target'."
fi 