# 使用 biocontainers 作为基础镜像
FROM biocontainers/biocontainers:latest

# --- ARGs for build-time configuration ---
ARG SETUP_USER=devuser
ARG SETUP_USER_PASSWORD=password
ARG LANG=zh_CN.UTF-8
ARG TERM=xterm-256color
ARG TIMEZONE=Asia/Shanghai
ARG ENABLE_SSH=yes
ARG SSH_PORT=22
ARG ENABLE_SUPERVISOR=yes
ARG ENABLE_SUDO=yes
ARG INSTALL_OH_MY_ZSH=yes
ARG INSTALL_COMMON_TOOLS=yes
ARG COPY_SSH_KEY=no
ARG AUTHORIZED_KEYS_FILE=""
ARG http_proxy
ARG https_proxy
ARG no_proxy

# Set build-time proxies if ARGs are provided
ENV DEBIAN_FRONTEND=noninteractive
ENV http_proxy=${http_proxy} \\
    https_proxy=${https_proxy} \\
    no_proxy=${no_proxy}

# --- Run Unified Common User Setup Script ---
# This script handles:
# - User creation (name, password from ARGs)
# - Sudo setup
# - SSH server setup (if ENABLE_SSH=yes)
# - Supervisor setup (if ENABLE_SUPERVISOR=yes, to manage sshd)
# - Oh My Zsh installation (if INSTALL_OH_MY_ZSH=yes)
# - Common tools installation (if INSTALL_COMMON_TOOLS=yes)
# - Locale and timezone setup
COPY ../../common/docker-setup-scripts/unified-common-setup.sh /tmp/unified-common-setup.sh
RUN chmod +x /tmp/unified-common-setup.sh && \\
    bash /tmp/unified-common-setup.sh && \\
    rm /tmp/unified-common-setup.sh

# Environment variables for the created user
ENV LANG=${LANG} \\
    TERM=${TERM} \\
    USER=${SETUP_USER} \\
    HOME=/home/${SETUP_USER}

# Switch to the created user
USER ${SETUP_USER}
WORKDIR /home/${SETUP_USER}

# Expose SSH port (defined by ARG, default 22, actual mapping in docker-compose)
EXPOSE ${SSH_PORT}

# Default command to start supervisord (if enabled)
# The unified script sets up supervisord.conf in /etc/supervisor/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# VOLUME [\"/data\", \"/data1\", \"/workspace\"] # Volumes are better managed in docker-compose.yaml