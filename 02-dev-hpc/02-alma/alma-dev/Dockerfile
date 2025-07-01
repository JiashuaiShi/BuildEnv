#
# AlmaLinux Development Image for HPC (C++/Java)
#
# This Dockerfile builds on top of the 'alma-base:latest' image.
# It installs C++ and Java development toolchains.
#
ARG BASE_IMAGE=alma-base:latest
FROM ${BASE_IMAGE}

LABEL maintainer="Cascade AI Assistant"
LABEL description="HPC development environment with C++ (GCC, Clang) and Java (OpenJDK, Maven)."

# --- Install Development Tools ---
# Install C/C++ toolchain, Java, and other essential tools.
# Using a single RUN command to optimize layers.
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
    # C/C++
    cmake \
    clang \
    gdb \
    valgrind \
    # Java
    java-17-openjdk-devel \
    maven \
    # Other utilities
    git \
    vim \
    htop \
    && dnf clean all && \
    rm -rf /var/cache/dnf/*

# --- User-specific Setup ---
# Switch to the non-root user created in the base image.
USER shijiashuai
WORKDIR /home/shijiashuai

# Install oh-my-zsh for the user
# Check if .oh-my-zsh exists to avoid re-running on rebuilds
RUN if [ ! -d ".oh-my-zsh" ]; then \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"; \
fi

# --- Final Setup ---
# Switch back to root to set the default working directory for the container.
USER root
WORKDIR /workspace
