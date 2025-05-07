# Biocontainers Development Environment

This component provides a Dockerized development environment based on `biocontainers/biocontainers:latest`. It is pre-configured with a user (`${SSH_USER_NAME:-shijiashuai}`), SSH access, sudo privileges, and common development tools via the `unified-common-setup.sh` script.

## Overview

-   **Base Image:** `biocontainers/biocontainers:latest`
-   **Purpose:** Provides a customizable and interactive development environment for bioinformatics tasks that benefit from the Biocontainers base.
-   **Key Features:**
    -   User `${SSH_USER_NAME:-shijiashuai}` with password (set in `.env` or via build-arg).
    -   SSH server running for remote access.
    -   `sudo` privileges for the user.
    -   Oh My Zsh pre-installed.
    -   Supervisord to manage services (e.g., `sshd`).
-   **Management:** Uses `1-build.sh` to build the image and `2-dev-cli.sh` for lifecycle management (start, stop, ssh, exec, etc.).

## Files

-   `Dockerfile`: Defines the image, incorporating `unified-common-setup.sh` for environment setup.
-   `docker-compose.yaml`: Configures the service, including build arguments, port mappings, and volumes.
-   `.env`: Contains environment variables for image name, tag, container name, SSH port, user credentials, etc. **Remember to set a secure `USER_PASSWORD`!**
-   `1-build.sh`: Script to build the Docker image, passing necessary build arguments.
-   `2-dev-cli.sh`: CLI script for managing the development environment.

## Prerequisites

-   Docker
-   Docker Compose

## Setup and Usage

1.  **Configure Environment:**
    -   Copy or create `.env` in this directory (`BioComponents/biocontainers/.env`).
    -   **Crucially, set `USER_PASSWORD` to a strong password.**
    -   Adjust `BIO_BIOCONTAINERS_SSH_PORT` if the default (e.g., 2203) conflicts with other services.
    -   Other variables like `SSH_USER_NAME`, `BIO_BIOCONTAINERS_IMAGE_REPO`, etc., can be customized.

2.  **Build the Image:**
    Navigate to this directory and run:
    ```bash
    ./1-build.sh
    ```
    This will use `docker-compose build` and pass arguments from `.env` and the `docker-compose.yaml` file to the `Dockerfile`.

3.  **Manage the Environment:**
    Use `2-dev-cli.sh` for common operations:

    *   **Start the environment:**
        ```bash
        ./2-dev-cli.sh start
        ```

    *   **SSH into the environment:**
        The SSH port and user are taken from `.env`.
        ```bash
        ./2-dev-cli.sh ssh
        # Or manually: ssh <your_ssh_user>@localhost -p <your_ssh_port_from_env>
        ```

    *   **Execute a command or open a shell (via docker-compose exec):**
        ```bash
        ./2-dev-cli.sh exec
        # or ./2-dev-cli.sh exec <your_command>
        ```

    *   **Stop the environment:**
        ```bash
        ./2-dev-cli.sh stop
        ```

    *   **Stop and remove the container:**
        ```bash
        ./2-dev-cli.sh rm
        ```

    *   **View status or logs:**
        ```bash
        ./2-dev-cli.sh status
        ./2-dev-cli.sh logs
        ```

    *   **Remove the built image:**
        ```bash
        ./2-dev-cli.sh rmi
        ```

## Customization

-   **User/Password/SSH Port:** Modify values in `.env` and rebuild if necessary (though some `2-dev-cli.sh` commands pick up `.env` changes at runtime).
-   **Installed Software:** Modify the `Dockerfile` (e.g., add more `apt-get install` lines or custom setup steps AFTER the `unified-common-setup.sh` script) and rebuild using `./1-build.sh`.
-   **Base Image:** Change the `FROM` line in `Dockerfile` if a different base from Biocontainers is needed. 