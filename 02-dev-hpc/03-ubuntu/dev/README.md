# Ubuntu HPC Development Environment

This directory contains the configuration for the Ubuntu-based HPC development environment.

## Features

- **Base Image**: Inherits from `ubuntu-base:latest`.
- **C++ Toolchain**: GCC, Clang, CMake, GDB, Valgrind.
- **Java Toolchain**: OpenJDK 17, Maven.
- **Shell**: Zsh with Oh My Zsh, auto-suggestions, and syntax highlighting.
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

4.  **Execute a Command**:
    ```bash
    ./dev-cli.sh exec <your-command>
    ```

5.  **Stop the Container**:
    ```bash
    ./dev-cli.sh stop
    ```
