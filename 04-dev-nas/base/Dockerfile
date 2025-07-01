#
# NAS Base Image for Development/Management
#
# This Dockerfile sets up a base environment with Samba, NFS tools,
# a non-root user, SSH access, and essential tools on AlmaLinux.
#
ARG ALMA_VERSION=9
FROM almalinux:${ALMA_VERSION}

LABEL maintainer="Cascade AI Assistant"
LABEL description="Base image for NAS with Samba, NFS, user setup, and SSH."

# --- Environment Variables ---
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# --- Build Arguments ---
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=phoenix2024
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- Package Installation ---
RUN dnf -y update && dnf -y install \
    # Basic utilities
    sudo \
    zsh \
    wget \
    curl \
    # NAS Tools
    samba \
    nfs-utils \
    # SSH and process management
    openssh-server \
    python3-pip \
    && pip3 install supervisor \
    # Clean up
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

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
# 22 for SSH, 139/445 for Samba, 111/2049 for NFS
EXPOSE 22 139 445 111 2049

# Use supervisord to start and manage the sshd service.
CMD ["/usr/bin/python3", "-m", "supervisor.supervisord", "-c", "/etc/supervisor/supervisord.conf"]
