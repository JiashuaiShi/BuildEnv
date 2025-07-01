#
# Web Development Image
#
# This Dockerfile builds upon the 'web-base' image to create a full-featured
# development environment for modern web frameworks.
#
ARG BASE_IMAGE=web-base:latest
FROM ${BASE_IMAGE}

LABEL maintainer="Cascade AI Assistant"
LABEL description="Web development environment with Node.js, Python, and common frontend tools."

# --- Build Arguments ---
ARG DEV_USER=shijiashuai

# --- Install Global Node Packages & Dev Tools ---
# Switch to root to install packages.
USER root

RUN npm install -g 
    create-react-app 
    @vue/cli 
    # Add any other global npm packages here
    && apt-get update && apt-get install -y --no-install-recommends 
    git 
    vim 
    htop 
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
# Switch back to root. Supervisord (from base image) will manage processes.
USER root

# The CMD is inherited from the base image.
