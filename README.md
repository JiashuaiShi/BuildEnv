# BuildEnv: Dockerized Development Environments

This project provides a collection of pre-configured Dockerized development environments aimed at standardizing and simplifying the setup process for various programming languages and tools.

## Overview

The main goal is to offer consistent, reproducible, and enhanced development environments with good defaults, including Chinese language support, common development tools, and easy-to-use management scripts.

## Directory Structure

-   **/Environments**: Contains Dockerfiles, docker-compose files, and specific configurations for different operating systems and development stacks (e.g., `alma9`, `ubuntu/dev`).
    -   Each subdirectory typically includes:
        -   `Dockerfile`: Defines the image build process.
        -   `docker-compose.yaml`: For orchestrating the container services.
        -   `1-build.sh`: Script to build the Docker image.
        -   `2-dev-cli.sh`: Script to manage the lifecycle of the development container (start, stop, exec, etc.).
        -   `README.md`: Specific instructions for that environment.
-   **/common**: Contains scripts and configuration files shared across multiple environments.
    -   `docker-setup-scripts/`: Scripts used during the `docker build` phase (e.g., `unified-common-setup.sh`).
-   **/scripts**: Contains utility and management scripts that operate on the environments or the project itself (e.g., `migrate_containers.sh` for migrating container images).
    -   See `scripts/README.md` for details on `migrate_containers.sh`.
-   **/tmp**: (Ignored by git) Used for temporary files, testing, and experimental setups.
-   `ROADMAP.md`: Outlines future development plans and TODOs for the project.
-   `.gitignore`: Specifies intentionally untracked files that Git should ignore.
-   `README.md`: This file - provides an overview of the project.

## Getting Started

1.  **Clone the repository.**
2.  **Navigate to a specific environment directory** under `Environments/` (e.g., `cd Environments/alma9`).
3.  **Review the environment-specific `README.md`** for any prerequisites or special instructions.
4.  **Build the Docker image**: Typically by running `./1-build.sh`.
5.  **Start and manage the container**: Typically using `./2-dev-cli.sh` (e.g., `./2-dev-cli.sh start`, `./2-dev-cli.sh exec`).

## Key Features (Ongoing Development)

-   Standardized user setup (`shijiashuai` with sudo privileges).
-   Chinese language support (`zh_CN.UTF-8`).
-   Common development tools pre-installed.
-   Supervisord for managing services within containers.
-   Scripts for easy environment management and migration.

Please refer to the `ROADMAP.md` for planned enhancements. 