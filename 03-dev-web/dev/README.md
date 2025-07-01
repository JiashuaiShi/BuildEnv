# Web Development Environment

This directory contains the configuration for the general-purpose web development environment.

## Features

- **Base Image**: Inherits from `web-base:latest`.
- **Runtimes**: Node.js (LTS) and Python3.
- **Frontend Tools**: `create-react-app`, `@vue/cli` installed globally.
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

3.  **Connect via SSH**:
    ```bash
    ./dev-cli.sh ssh
    ```

4.  **Execute a Command in the Container**:
    ```bash
    ./dev-cli.sh exec <your-command>
    ```

5.  **Stop the Container**:
    ```bash
    ./dev-cli.sh stop
    ```
