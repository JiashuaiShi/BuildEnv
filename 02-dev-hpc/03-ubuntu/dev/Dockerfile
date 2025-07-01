#
# Ubuntu Development Image for HPC
#
# This Dockerfile builds upon the 'ubuntu-base' image to create a full-featured
# development environment for C++ and Java.
#
ARG BASE_IMAGE=ubuntu-base:latest
FROM ${BASE_IMAGE}

LABEL maintainer="Cascade AI Assistant"
LABEL description="HPC development environment with C++, Java, and other tools on Ubuntu."

# --- Build Arguments ---
# The user is already created in the base image. We just need to know who it is.
ARG DEV_USER=shijiashuai

# --- Install Development Tools ---
# Switch to root to install packages.
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    # C++ Toolchain
    g++ \
    clang \
    cmake \
    gdb \
    valgrind \
    # Java Toolchain
    openjdk-17-jdk \
    maven \
    # Common tools
    git \
    vim \
    htop \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- User-specific Setup (oh-my-zsh) ---
# Switch to the dev user to install user-level tools.
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# --- Final Steps ---
# Switch back to root user. The container will be started as root by Docker,
# and supervisord will manage processes. The user can connect as DEV_USER.
USER root

# The CMD is inherited from the base image.
