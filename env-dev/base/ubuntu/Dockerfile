# Base Dockerfile for Ubuntu 22.04
# This image is the foundation for all other Ubuntu-based environments.
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Basic setup: update, install common utilities, and create a dev user
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    git \
    curl \
    wget \
    unzip \
    ca-certificates && \
    useradd -m -s /bin/bash devuser && \
    echo "devuser:devuser" | chpasswd && \
    adduser devuser sudo && \
    rm -rf /var/lib/apt/lists/*

# Set the default user
USER devuser
WORKDIR /home/devuser
