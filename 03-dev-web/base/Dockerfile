#
# Web Base Image for Development
#
# This Dockerfile sets up a base environment with Node.js, Python,
# a non-root user, SSH access, and essential tools.
#
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL maintainer="Cascade AI Assistant"
LABEL description="Base image for web development with Ubuntu, Node.js, Python, user setup, and SSH."

# --- Environment Variables ---
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    NODE_VERSION=20

# --- Build Arguments ---
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=phoenix2024
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- Package Installation ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Basic utilities
    sudo \
    ca-certificates \
    wget \
    curl \
    gnupg \
    zsh \
    # Python
    python3 \
    python3-pip \
    # SSH and process management
    openssh-server \
    supervisor \
    # Node.js setup from NodeSource
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    # Set timezone and clean up
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Configuration & User Setup ---
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# Execute the setup script to create the user, then generate SSH host keys.
RUN chmod +x /tmp/unified-user-setup.sh && \
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    rm /tmp/unified-user-setup.sh && \
    ssh-keygen -A && \
    mkdir -p /var/run/sshd

# --- Ports & Entrypoint ---
EXPOSE 22 3000 8000 8080

# Use supervisord to start and manage the sshd service.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
