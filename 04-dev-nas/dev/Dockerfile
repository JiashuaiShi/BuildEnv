#
# NAS Development/Management Image
#
# This Dockerfile builds upon the 'nas-base' image.
# It can be used to add higher-level management tools or web UIs in the future.
#
ARG BASE_IMAGE=nas-base:latest
FROM ${BASE_IMAGE}

LABEL maintainer="Cascade AI Assistant"
LABEL description="NAS management environment with Samba, NFS, and Oh My Zsh."

# --- Build Arguments ---
ARG DEV_USER=shijiashuai

# --- Install Additional Tools ---
# Switch to root to install packages.
USER root

RUN dnf -y install git vim htop && dnf clean all

# --- User-specific Setup (oh-my-zsh) ---
# Switch to the dev user to install user-level tools.
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# --- Final Steps ---
# Switch back to root. Supervisord (from base image) will manage processes.
USER root

# The CMD is inherited from the base image.
