# Dockerfile for the Supervisor variant
# Extends the base Ubuntu image with Supervisor for process management.
ARG BASE_IMAGE_REPO=lessup/ubuntu
ARG BASE_IMAGE_TAG=22.04
FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG}

# Switch to root to install software
USER root

# Install supervisor
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy supervisor configuration and set it up
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# The command to run supervisor, which will manage other processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
