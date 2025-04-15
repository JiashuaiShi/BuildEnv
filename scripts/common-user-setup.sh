#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Basic Tooling ---
apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true
apt-get install -y --no-install-recommends --allow-unauthenticated \
    sudo \
    locales-all \
    zsh \
    openssh-server \
    supervisor \
    ca-certificates \
    wget \
    curl \
    gnupg \
    gpg
apt-get clean || true
rm -rf /var/lib/apt/lists/*

# --- Locale ---
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

# --- User & Group Setup ---
groupadd -g 2000 lush-dev || true # Allow existing group
useradd -m -u 2034 -g lush-dev -s /usr/bin/zsh shijiashuai || true # Allow existing user
echo 'shijiashuai:phoenix2024' | chpasswd
usermod -aG sudo shijiashuai
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# --- Workspace & Data Dirs ---
mkdir -p /workspace && chown -R shijiashuai:lush-dev /workspace
mkdir -p /data-lush/lush-dev/shijiashuai && chown -R shijiashuai:lush-dev /data-lush

# --- SSH Configuration ---
mkdir -p /var/run/sshd
mkdir -p /etc/ssh
echo "# Package generated configuration file" > /etc/ssh/sshd_config
echo "# See the sshd_config(5) manpage for details" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "PrintMotd no" >> /etc/ssh/sshd_config
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
echo "Subsystem sftp /usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config
if [ -f /etc/pam.d/sshd ]; then
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd;
fi

# --- Supervisor Base Config ---
mkdir -p /etc/supervisor/conf.d
mkdir -p /var/log/supervisor
touch /var/log/supervisor/supervisord.log
touch /var/log/supervisor/sshd.log
touch /var/log/supervisor/sshd.err
chown -R root:root /var/log/supervisor
chmod -R 755 /var/log/supervisor

echo "Common setup script completed." 