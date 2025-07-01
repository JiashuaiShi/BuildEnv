# NAS Development & Management Environment

This directory contains the configuration for the NAS (Network Attached Storage) environment.

## Features

- **Base Image**: Inherits from `nas-base:latest` (AlmaLinux-based).
- **Core Services**: Samba and NFS utilities are installed in the base image.
- **Shell**: Zsh with Oh My Zsh for an enhanced terminal experience.
- **Containerized**: Managed by Docker and Docker Compose.

## How to Use

1.  **Build the Environment**:
    ```bash
    ./build.sh
    ```

2.  **Start the Container**:
    ```bash
    ./start.sh
    ```
    This will also create a `./share` directory on the host, which is mounted into the container at `/export/share`.

3.  **Connect via SSH**:
    ```bash
    ./dev-cli.sh ssh
    ```

4.  **Stop the Container**:
    ```bash
    ./dev-cli.sh stop
    ```
