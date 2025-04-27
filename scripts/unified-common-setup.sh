#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration (Hardcoded for now, consider using ARGs) ---
SETUP_USER_NAME="shijiashuai"
SETUP_USER_ID="2034"
SETUP_GROUP_NAME="lush-dev"
SETUP_GROUP_ID="2000"
SETUP_USER_PASSWORD="phoenix2024"
SETUP_LOCALE="en_US.UTF-8"

# --- OS Detection ---
OS_ID=""
if [ -f /etc/os-release ]; then
    OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
else
    echo "Error: Cannot detect operating system." >&2
    exit 1
fi

echo "Detected OS: ${OS_ID}"

# --- Package Management & Basic Tooling ---
echo "Installing base packages..."
if [ "$OS_ID" == "ubuntu" ] || [ "$OS_ID" == "debian" ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true
    # Install supervisor from apt
    apt-get install -y --no-install-recommends --allow-unauthenticated \
        sudo \
        locales \
        zsh \
        openssh-server \
        supervisor \
        ca-certificates \
        wget \
        curl \
        gnupg \
        gpg \
        git # Ensure git is installed
    apt-get clean || true
    rm -rf /var/lib/apt/lists/*

    # Configure Locale
    echo "${SETUP_LOCALE} UTF-8" > /etc/locale.gen
    locale-gen ${SETUP_LOCALE}
    update-locale LANG=${SETUP_LOCALE} LANGUAGE=en_US:en

elif [ "$OS_ID" == "almalinux" ] || [ "$OS_ID" == "centos" ] || [ "$OS_ID" == "rhel" ] || [ "$OS_ID" == "fedora" ]; then
    dnf -y update || true
    # Enable EPEL for supervisor if not CentOS Stream/Fedora
    if [[ "$OS_ID" == "almalinux" || "$OS_ID" == "centos" || "$OS_ID" == "rhel" ]]; then
       dnf -y install epel-release || true # May already be present
    fi
    # Install supervisor from dnf/epel
    dnf -y install \
        sudo \
        zsh \
        openssh-server \
        supervisor \
        ca-certificates \
        wget \
        curl \
        gnupg \
        gpg \
        git # Ensure git is installed
    dnf -y clean all
    rm -rf /var/cache/dnf/*

    # Configure Locale (Basic setup, might need glibc-langpack-en if minimal base)
    # localectl set-locale LANG=${SETUP_LOCALE} # Use if localectl is available
    echo "LANG=${SETUP_LOCALE}" > /etc/locale.conf # Fallback

else
    echo "Error: Unsupported operating system: ${OS_ID}" >&2
    exit 1
fi

# --- Locale Env Vars (Set for subsequent script steps) ---
export LANG=${SETUP_LOCALE}
export LANGUAGE=en_US:en
export LC_ALL=${SETUP_LOCALE}

# --- User & Group Setup ---
echo "Setting up user and group..."
groupadd -g ${SETUP_GROUP_ID} ${SETUP_GROUP_NAME} 2>/dev/null || echo "Group ${SETUP_GROUP_NAME} already exists or GID ${SETUP_GROUP_ID} is in use."
useradd -m -d /home/${SETUP_USER_NAME} -u ${SETUP_USER_ID} -g ${SETUP_GROUP_NAME} -s /usr/bin/zsh ${SETUP_USER_NAME} 2>/dev/null || echo "User ${SETUP_USER_NAME} already exists or UID ${SETUP_USER_ID} is in use."
echo "${SETUP_USER_NAME}:${SETUP_USER_PASSWORD}" | chpasswd

# Configure passwordless sudo for the specific user
echo "Configuring passwordless sudo for user ${SETUP_USER_NAME}..."
echo "${SETUP_USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${SETUP_USER_NAME}_nopasswd
chmod 0440 /etc/sudoers.d/${SETUP_USER_NAME}_nopasswd

# --- Workspace Setup ---
echo "Creating /workspace directory..."
mkdir -p /workspace
chown -R ${SETUP_USER_NAME}:${SETUP_GROUP_NAME} /workspace

# --- SSH Configuration ---
echo "Configuring SSH server..."
mkdir -p /var/run/sshd /etc/ssh
# Generate host keys if they don't exist
ssh-keygen -A
# Ensure correct permissions for sshd directory
chmod 700 /etc/ssh

# Modify default sshd_config using sed (safer than overwriting)
SSHD_CONFIG_FILE=/etc/ssh/sshd_config
if [ -f "$SSHD_CONFIG_FILE" ]; then
    echo "Modifying $SSHD_CONFIG_FILE..."
    # Allow Password Authentication (for dev convenience)
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' $SSHD_CONFIG_FILE
    # Disallow Root Login (Security Best Practice)
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' $SSHD_CONFIG_FILE
    # Ensure other necessary defaults (might vary slightly by distro defaults)
    grep -qxF 'ChallengeResponseAuthentication no' $SSHD_CONFIG_FILE || echo 'ChallengeResponseAuthentication no' >> $SSHD_CONFIG_FILE
    grep -qxF 'UsePAM yes' $SSHD_CONFIG_FILE || echo 'UsePAM yes' >> $SSHD_CONFIG_FILE
    grep -qxF 'X11Forwarding yes' $SSHD_CONFIG_FILE || echo 'X11Forwarding yes' >> $SSHD_CONFIG_FILE
    grep -qxF 'PrintMotd no' $SSHD_CONFIG_FILE || echo 'PrintMotd no' >> $SSHD_CONFIG_FILE
    grep -qxF 'AcceptEnv LANG LC_*' $SSHD_CONFIG_FILE || echo 'AcceptEnv LANG LC_*' >> $SSHD_CONFIG_FILE
    # Check if Subsystem sftp line exists before adding
    if ! grep -q 'Subsystem\s*sftp' $SSHD_CONFIG_FILE; then
         # Path might differ, check common locations
         SFTP_SERVER_PATH=$(find /usr/lib* -name sftp-server | head -n 1)
         if [ -n "$SFTP_SERVER_PATH" ]; then
             echo "Subsystem sftp $SFTP_SERVER_PATH" >> $SSHD_CONFIG_FILE
         else
             echo "Warning: sftp-server not found, Subsystem sftp not added."
         fi
    fi
else
    echo "Warning: $SSHD_CONFIG_FILE not found. Skipping SSH configuration modification."
fi

# Modify PAM if needed (Ubuntu specific fix)
if [ -f /etc/pam.d/sshd ] && [ "$OS_ID" == "ubuntu" ]; then
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd;
fi

# --- Supervisor Base Config ---
echo "Setting up Supervisor directories..."
SUPERVISOR_CONF_DIR=/etc/supervisor/conf.d # Standard path for package install
mkdir -p ${SUPERVISOR_CONF_DIR}
mkdir -p /var/log/supervisor
# supervisord runs as root, so root should own logs
touch /var/log/supervisor/supervisord.log
touch /var/log/supervisor/sshd.log
touch /var/log/supervisor/sshd.err
# Ensure correct permissions for log files and directory
chmod 640 /var/log/supervisor/*
chown root:root /var/log/supervisor/* # Or root:adm if supervisor runs as adm
chmod 755 /var/log/supervisor

echo "Unified common setup script completed."