#
# AlmaLinux Base Image for HPC Development
#
# This Dockerfile sets up a base environment with a non-root user,
# SSH access, and basic tools, managed by Supervisor.
#
ARG ALMA_VERSION=9
FROM almalinux:${ALMA_VERSION}

LABEL maintainer="Cascade AI Assistant"
LABEL description="Base image for HPC development with AlmaLinux, user setup, and SSH."

# --- Environment Variables ---
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# --- Build Arguments ---
# Defines the user, group, and password for the non-root user.
# Example: docker build --build-arg DEV_PASSWORD=your_pass -t alma-base .
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=phoenix2024
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- Package Installation ---
# Install essential packages for a development environment.
RUN dnf -y update && dnf -y install \
    sudo \
    zsh \
    openssh-server \
    python3-pip \
    wget \
    curl \
    gnupg \
    ca-certificates \
    # Install supervisor for process management
    && pip3 install supervisor \
    # Clean up dnf cache to reduce image size
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- Configuration & User Setup ---
# Copy configuration files and the unified setup script.
COPY supervisord.conf /etc/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# Execute the setup script to create the user, then generate SSH host keys.
RUN chmod +x /tmp/unified-user-setup.sh && \
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    rm /tmp/unified-user-setup.sh && \
    # Generate SSH host keys
    ssh-keygen -A

# --- Ports & Entrypoint ---
EXPOSE 22

# Use supervisord to start and manage the sshd service.
CMD ["/usr/bin/python3", "-m", "supervisor.supervisord", "-c", "/etc/supervisord.conf"]
