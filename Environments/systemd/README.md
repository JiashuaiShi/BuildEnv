# Systemd Based Development Environments

This directory contains Docker-based development environments built upon base images that use `systemd` as the init system. This allows for running services like `sshd` within the container in a standard way.

Two environments are provided:

1.  **`alma9-dev`**: Based on AlmaLinux 9.
2.  **`ubuntu-dev`**: Based on Ubuntu (likely 22.04 LTS, check Dockerfile for specifics).

## Features

Both environments aim to provide a consistent and comprehensive development experience, including:

*   **SSH Access**: Secure remote access into the running container.
*   **User Setup**: A non-root user (`shijiashuai`, uid/gid 1000) with passwordless `sudo`.
*   **Systemd Integration**: Proper service management within the container.
*   **Multi-language Support**:
    *   **C/C++**: GCC, Clang, CMake, Ninja, GDB, Valgrind.
    *   **Java**: OpenJDK 8, 11, 17 with easy switching (`jdk8`, `jdk11`, `jdk17`, `jdk` commands).
    *   **Python**: Python 3, pip, venv. The Ubuntu environment also includes Miniconda for more advanced package management.
*   **Common Dev Tools**: Git, Vim, Neovim, tmux, curl, wget, etc.
*   **Shell Enhancements**: `zsh` with `oh-my-zsh` (including auto-suggestions and syntax highlighting) available alongside `bash`.
*   **Container Management CLI**: Each environment has a `2-dev-cli.sh` script for easy management.

**Ubuntu Specific Features:**

*   Includes Go, Rust, SBT (Scala Build Tool).
*   Includes Miniconda for Python environment management.
*   Uses `apt` for package management.

**AlmaLinux Specific Features:**

*   Uses `dnf` (or `microdnf`) for package management.

## Usage

Navigate to the specific environment directory (`alma9-dev` or `ubuntu-dev`) first.

1.  **Build the Environment:**
    ```bash
    ./1-build.sh
    ```
    This script uses `docker-compose build` to construct the Docker image based on the `Dockerfile` and `docker-compose.yaml` in the directory. It will also stop and remove any existing container from a previous build.

    *   **Note for `ubuntu-dev`**: Running `./1-build.sh` in the `ubuntu-dev` directory will *first* build (or update) the base image (`shuai/ubuntu-base-systemd:latest`) using the `Dockerfile` located in the `../ubuntu-base` directory, and then proceed to build the `ubuntu-dev` image.

2.  **Manage the Container using the CLI Tool:**
    ```bash
    ./2-dev-cli.sh [command]
    ```
    Available commands:
    *   `start`: Starts the container in detached mode (`docker-compose up -d`) and displays connection info.
    *   `stop`: Stops the running container (`docker-compose stop`).
    *   `down`: Stops and removes the container, network, etc. (`docker-compose down`).
    *   `restart`: Restarts the container (`docker-compose restart`).
    *   `ssh`: Opens an SSH session into the running container.
    *   `status`: Shows the container status (`docker-compose ps`).
    *   `logs`: Tails the container logs (`docker-compose logs --follow`).
    *   `exec "<command>"`: Executes a command inside the running container.
    *   `clean`: Stops/removes the container and attempts to remove the Docker image.
    *   `build`: (Re)builds the image by calling `1-build.sh`.
    *   `help`: Shows the help message.

3.  **Connect via SSH:**
    Once started, you can connect using the details provided by `./2-dev-cli.sh start` or directly:
    *   **AlmaLinux:** `ssh -p 28981 shijiashuai@localhost` (Password: phoenix2024)
    *   **Ubuntu:** `ssh -p 28982 shijiashuai@localhost` (Default Password: password - CHANGE THIS!)

4.  **Switching JDK Versions (inside the container):**
    Use the provided aliases/functions:
    ```bash
    jdk8    # Switch to Java 8
    jdk11   # Switch to Java 11
    jdk17   # Switch to Java 17
    jdk     # Check current version and alternatives config
    ```
    *Note: These aliases work by sourcing the `/usr/local/bin/jdk` script. Make sure your shell configuration (`.bashrc`, `.zshrc`) is correctly loading aliases if you encounter issues.* 

## Customization

*   **Dockerfile**: Modify the `Dockerfile` in each environment directory to add or remove packages and tools.
*   **docker-compose.yaml**: Adjust service definitions, ports, volumes, environment variables etc.
*   **Scripts**: Modify the `1-build.sh` or `2-dev-cli.sh` scripts if needed. 