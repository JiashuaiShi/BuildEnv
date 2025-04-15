#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Basic Tooling (using dnf) ---
dnf -y update || true # Update system
dnf -y install \
    sudo \
    zsh \
    openssh-server \
    python3-pip \
    wget \
    curl \
    gnupg \
    gpg \
    ca-certificates
pip3 install supervisor # Install supervisor via pip
dnf -y clean all
rm -rf /var/cache/dnf/*

# --- Locale (Assuming base image handles locale or needs different setup) ---
# Setting locale might differ on AlmaLinux compared to Ubuntu
# export LANG=en_US.UTF-8
# export LANGUAGE=en_US:en
# export LC_ALL=en_US.UTF-8

# --- User & Group Setup ---
groupadd -g 2000 lush-dev || true # Allow existing group
useradd -m -u 2034 -g lush-dev -s /usr/bin/zsh shijiashuai || true # Allow existing user
echo 'shijiashuai:phoenix2024' | chpasswd
usermod -aG wheel shijiashuai # Add to 'wheel' group for sudo on RHEL-based systems
# Configure sudoers for the wheel group (common practice on RHEL-based systems)
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel_nopasswd
# Alternatively, keep the specific user setting if preferred:
# echo 'shijiashuai ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/shijiashuai_nopasswd

# --- Workspace & Data Dirs ---
mkdir -p /workspace && chown -R shijiashuai:lush-dev /workspace
mkdir -p /data-lush/lush-dev/shijiashuai && chown -R shijiashuai:lush-dev /data-lush

# --- SSH Configuration ---
ssh-keygen -A # Generate host keys if not present
mkdir -p /var/run/sshd /etc/ssh
# Basic sshd_config, assuming PermitRootLogin and PasswordAuthentication are desired
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
# PAM configuration for sshd might differ, adjust if needed

# --- Supervisor Base Config ---
# Supervisor config path might differ if installed via pip
SUPERVISOR_CONF_DIR=/etc/supervisor/conf.d
mkdir -p ${SUPERVISOR_CONF_DIR}
mkdir -p /var/log/supervisor
# Assuming supervisor runs as root, logs owned by root
touch /var/log/supervisor/supervisord.log
touch /var/log/supervisor/sshd.log
touch /var/log/supervisor/sshd.err
chown -R root:root /var/log/supervisor
chmod -R 755 /var/log/supervisor

echo "Common AlmaLinux setup script completed." 