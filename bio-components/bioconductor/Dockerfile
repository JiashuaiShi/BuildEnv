# FROM bioconductor/bioconductor_docker:latest
# Opting for a more standard base like ubuntu and installing R/Bioconductor via script might be more flexible
# For now, we keep the original base to maintain its specific Bioconductor setup.
FROM bioconductor/bioconductor_docker:latest

# --- ARGs for build-time configuration ---
ARG SETUP_USER=devuser
ARG SETUP_USER_PASSWORD=password
ARG LANG=zh_CN.UTF-8
ARG TERM=xterm-256color
ARG TIMEZONE=Asia/Shanghai
ARG ENABLE_SSH=yes
ARG SSH_PORT=22 # Internal port, mapping done in compose
ARG ENABLE_SUPERVISOR=yes
ARG ENABLE_SUDO=yes
ARG INSTALL_OH_MY_ZSH=yes
ARG INSTALL_COMMON_TOOLS=yes # For tools like vim, git, etc.
ARG ADD_PACKAGES=""
ARG COPY_SSH_KEY=no
ARG AUTHORIZED_KEYS_FILE=""
ARG http_proxy
ARG https_proxy
ARG no_proxy

# Set build-time proxies if ARGs are provided
ENV DEBIAN_FRONTEND=noninteractive
ENV http_proxy=${http_proxy} \\
    https_proxy=${https_proxy} \\
    no_proxy=${no_proxy}

# --- Run Unified Common User Setup Script ---
COPY ../../common/docker-setup-scripts/unified-common-setup.sh /tmp/unified-common-setup.sh
RUN chmod +x /tmp/unified-common-setup.sh && \\
    bash /tmp/unified-common-setup.sh && \\
    rm /tmp/unified-common-setup.sh

# If RStudio Server or other services specific to Bioconductor are needed,
# they could be installed here or managed by a supervisor conf snippet.
# Example for RStudio (ensure it does not conflict with unified-common-setup.sh supervisor part):
# RUN apt-get update && apt-get install -y rstudio-server && apt-get clean && rm -rf /var/lib/apt/lists/*
# RUN echo "www-address=0.0.0.0" >> /etc/rstudio/rserver.conf
# RUN echo "[program:rstudio]\ncommand=/usr/lib/rstudio-server/bin/rserver --server-daemonize 0\nuser=${SETUP_USER}\nautostart=true\nautorestart=true\n" >> /etc/supervisor/conf.d/user_services.conf
# EXPOSE 8787 # For RStudio

# Environment variables for the created user
ENV LANG=${LANG} \\
    TERM=${TERM} \\
    USER=${SETUP_USER} \\
    HOME=/home/${SETUP_USER}

# Switch to the created user
USER ${SETUP_USER}
WORKDIR /home/${SETUP_USER}

# Expose SSH port (defined by ARG, default 22)
EXPOSE ${SSH_PORT}
# If RStudio is installed and configured for supervisor, expose its port too.
# EXPOSE 8787

# Default command to start supervisord (if enabled)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]