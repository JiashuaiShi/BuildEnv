# Dockerfile for the Systemd variant
# Extends the base Ubuntu image to enable Systemd.
ARG BASE_IMAGE_REPO=lessup/ubuntu
ARG BASE_IMAGE_TAG=22.04
FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG}

# Switch to root to perform setup
USER root

# Install systemd and other utils
RUN apt-get update && \
    apt-get install -y --no-install-recommends systemd systemd-sysv && \
    rm -rf /var/lib/apt/lists/*

# Enable systemd
CMD ["/sbin/init"]
