# Dockerfile for dev-cpp-python environment
# Extends the ubuntu-supervisor variant with C++ and Python development tools.
ARG VARIANT_IMAGE_REPO=lessup/ubuntu-supervisor
ARG VARIANT_IMAGE_TAG=22.04
FROM ${VARIANT_IMAGE_REPO}:${VARIANT_IMAGE_TAG}

# Install C++ and Python development tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gdb \
    cmake \
    python3 \
    python3-pip \
    python3-venv && \
    rm -rf /var/lib/apt/lists/*
