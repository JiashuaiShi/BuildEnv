#!/bin/bash
set -e

#
# Unified User Setup Script
#
# This script creates a non-root user with sudo privileges for both
# RHEL-based (AlmaLinux, CentOS) and Debian-based (Ubuntu) systems.
# It is designed to be called from a Dockerfile.
#

# --- Arguments ---
DEV_USER=${1:?"Usage: $0 <USER> <PASSWORD> <UID> <GROUP> <GID>"}
DEV_PASSWORD=${2:?"Usage: $0 <USER> <PASSWORD> <UID> <GROUP> <GID>"}
USER_UID=${3:?"Usage: $0 <USER> <PASSWORD> <UID> <GROUP> <GID>"}
DEV_GROUP=${4:?"Usage: $0 <USER> <PASSWORD> <UID> <GROUP> <GID>"}
GROUP_GID=${5:?"Usage: $0 <USER> <PASSWORD> <UID> <GROUP> <GID>"}

echo "Executing unified user setup for user '${DEV_USER}'..."

# --- OS Detection ---
if [ -f /etc/redhat-release ]; then
    OS_FAMILY="rhel"
    SUDO_GROUP="wheel"
    # Install shadow-utils to ensure 'chpasswd' is available
    if ! command -v chpasswd &> /dev/null; then
        dnf -y install shadow-utils
    fi
elif [ -f /etc/debian_version ]; then
    OS_FAMILY="debian"
    SUDO_GROUP="sudo"
    # Install passwd to ensure 'chpasswd' is available
    if ! command -v chpasswd &> /dev/null; then
        apt-get update && apt-get install -y passwd
    fi
else
    echo "Unsupported operating system." >&2
    exit 1
fi

echo "Detected OS family: ${OS_FAMILY}, sudo group: ${SUDO_GROUP}"

# --- User and Group Creation ---
echo "Creating group '${DEV_GROUP}' with GID ${GROUP_GID}..."
groupadd -g "${GROUP_GID}" "${DEV_GROUP}" || echo "Group already exists."

echo "Creating user '${DEV_USER}' with UID ${USER_UID}..."
useradd -m -s /bin/zsh -u "${USER_UID}" -g "${GROUP_GID}" "${DEV_USER}" || echo "User already exists."

# --- Set Password ---
echo "Setting password for user '${DEV_USER}'..."
echo "${DEV_USER}:${DEV_PASSWORD}" | chpasswd

# --- Sudo Configuration ---
echo "Configuring sudo access for group '${SUDO_GROUP}'..."
usermod -aG "${SUDO_GROUP}" "${DEV_USER}"

# Configure passwordless sudo for the group
SUDOERS_FILE="/etc/sudoers.d/90-nopasswd-${SUDO_GROUP}"
echo "%${SUDO_GROUP} ALL=(ALL) NOPASSWD: ALL" > "${SUDOERS_FILE}"
chmod 440 "${SUDOERS_FILE}"

echo "User '${DEV_USER}' created and configured successfully."
