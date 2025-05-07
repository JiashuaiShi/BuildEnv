# AlmaLinux 9 Development Environment

This directory contains the configuration for an AlmaLinux 9 based development environment.

## Overview

This environment is designed for general-purpose development and includes:

-   AlmaLinux 9 base.
-   Common development tools for C++, Java, Python, Go, Rust.
-   Pre-configured user `shijiashuai` with passwordless sudo.
-   SSH server enabled.
-   Chinese language support (`zh_CN.UTF-8`).
-   Miniconda for Python environment management.
-   Oh My Zsh with common plugins.
-   JDK (8, 11, 17) with a switcher script (`jdk`).
-   Services managed by Supervisord.

## Key Files

-   `Dockerfile`: Defines the image build process, leveraging the `common/docker-setup-scripts/unified-common-setup.sh` for base setup.
-   `docker-compose.yaml`: Configures the `shuai-alma9-dev` service.
-   `1-build.sh`: Script to build the Docker image for this environment. Ensure you have set any required build arguments (e.g., proxy settings if needed).
-   `2-dev-cli.sh`: Script to manage the container lifecycle (start, stop, exec, logs, etc.).
-   `supervisord.conf`: Configuration for services managed by Supervisor (e.g., sshd).
-   `jdk_switcher.sh`: Helper script to switch between installed JDK versions.

## Setup and Usage

1.  **Build the Image**:
    ```bash
    ./1-build.sh
    ```
    This will build the `shuai/alma9-dev:20250506` image (or as defined in `.env` / `2-dev-cli.sh`).

2.  **Run the Container**:
    Use the `2-dev-cli.sh` script for managing the container:
    ```bash
    # Start the container in detached mode
    ./2-dev-cli.sh start

    # Access the container shell (as shijiashuai)
    ./2-dev-cli.sh exec

    # View logs
    ./2-dev-cli.sh logs

    # Stop the container
    ./2-dev-cli.sh stop
    ```

## Configuration

-   Refer to the root `.env` file and `Environments/alma9/.env` (if it exists or you create one based on `2-dev-cli.sh` variables) for customizing container name, ports, image tags, etc.
-   The default user is `shijiashuai` with password `phoenix2024` (set in `common/docker-setup-scripts/unified-common-setup.sh`). This user has passwordless sudo access.
-   SSH is available on the port mapped in `docker-compose.yaml` (default host port 28981). Root login via SSH is disabled.

## Notes

-   This environment uses `common/docker-setup-scripts/unified-common-setup.sh` for the initial user and system configuration. 