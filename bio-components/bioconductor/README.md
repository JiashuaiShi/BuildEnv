# Bioconductor Development Environment

This component provides a Dockerized development environment based on the official `bioconductor/bioconductor_docker:latest` image. It is enhanced with a standard user (`${SSH_USER_NAME:-shijiashuai}`), SSH access, sudo, and common tools using the `unified-common-setup.sh` script.

## Overview

-   **Base Image:** `bioconductor/bioconductor_docker:latest`
-   **Purpose:** Offers an interactive environment for Bioconductor-based analysis and development, with user setup and SSH.
-   **Key Features (from `unified-common-setup.sh`):
    -   User `${SSH_USER_NAME:-shijiashuai}` (password from `.env`).
    -   SSH server.
    -   `sudo` privileges.
    -   Oh My Zsh.
    -   Supervisord (manages `sshd`).
-   **Potential additions (manual or scripted in Dockerfile):** RStudio Server.

## Files

-   `Dockerfile`: Uses `bioconductor/bioconductor_docker:latest` and integrates `unified-common-setup.sh`.
-   `docker-compose.yaml`: Defines the service, build args, ports (SSH, potentially RStudio), and volumes.
-   `.env`: For image name, tags, container name, SSH port, user credentials. **Set a strong `USER_PASSWORD`!**
-   `1-build.sh`: Builds the image using `docker-compose build`.
-   `2-dev-cli.sh`: Manages the environment (start, stop, ssh, etc.).

## Prerequisites

-   Docker
-   Docker Compose

## Setup and Usage

1.  **Configure `.env`:**
    -   Create/edit `BioComponents/bioconductor/.env`.
    -   Set `USER_PASSWORD` (mandatory).
    -   Adjust `BIO_BIOCONDUCTOR_SSH_PORT` (e.g., 2204) if needed.
    -   (Optional) If you plan to add RStudio server, you might add `BIO_BIOCONDUCTOR_RSTUDIO_PORT` to `.env` and uncomment relevant sections in `docker-compose.yaml` and `Dockerfile`.

2.  **Build the Image:**
    ```bash
    cd BioComponents/bioconductor/
    ./1-build.sh
    ```

3.  **Manage the Environment with `./2-dev-cli.sh`:**
    *   Start: `./2-dev-cli.sh start`
    *   SSH: `./2-dev-cli.sh ssh` (uses details from `.env`)
    *   Exec shell: `./2-dev-cli.sh exec`
    *   Stop: `./2-dev-cli.sh stop`
    *   Remove container: `./2-dev-cli.sh rm`
    *   Status/Logs: `./2-dev-cli.sh status`, `./2-dev-cli.sh logs`
    *   Remove image: `./2-dev-cli.sh rmi`

## Customizing for RStudio Server (Example)

If you need RStudio Server:
1.  **Dockerfile:**
    -   Uncomment or add `RUN apt-get update && apt-get install -y rstudio-server && ...`
    -   Add a supervisor configuration for rstudio-server, e.g., in `/etc/supervisor/conf.d/user_services.conf`.
    -   `EXPOSE 8787`
2.  **docker-compose.yaml:**
    -   Uncomment the RStudio port mapping: `- "${BIO_BIOCONDUCTOR_RSTUDIO_PORT:-8787}:8787"`
3.  **.env:**
    -   Define `BIO_BIOCONDUCTOR_RSTUDIO_PORT` (e.g., 8787).
4.  **2-dev-cli.sh:**
    -   You might add a helper command like `rstudio_url`.
5.  Rebuild the image with `./1-build.sh`.

Consult the `bioconductor/bioconductor_docker` documentation for more on the base image capabilities. 