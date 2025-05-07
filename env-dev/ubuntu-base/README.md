# Ubuntu Base Systemd Environment

This component provides a foundational Docker image based on Ubuntu Noble (24.04 LTS) with **systemd enabled** as the init process (PID 1). It's intended primarily as a base for other, more specialized development environment Dockerfiles that require systemd.

## Overview

-   **Base Image:** `ubuntu:noble`
-   **Key Features:**
    -   Systemd enabled and configured for container use.
    -   Essential packages like `sudo`, `dbus`, `locales`, `tzdata` installed.
    -   Locale set to `${LANG:-en_US.UTF-8}` (configurable via build ARGs).
    -   Problematic systemd services are masked.
    -   `dbus.service` and `systemd-logind.service` are enabled.
-   **Not Included:** This image does *not* pre-configure any non-root users or SSH services. These should be added by derived Dockerfiles (e.g., using `unified-common-setup.sh`).
-   **Image Name (from `.env`):** `${UBUNTU_BASE_SYSTEMD_IMAGE_REPO:-shuai/ubuntu-base-systemd}:${UBUNTU_BASE_SYSTEMD_IMAGE_TAG:-noble}`

## Files

-   `Dockerfile`: Defines the image build process.
-   `docker-compose.yaml`: Used for building the image via `1-build.sh` and for running basic test instances of this base image (as root).
-   `.env`: Configures image name, tag, default locale, and container name for testing.
-   `1-build.sh`: Script to build the Docker image.
-   `2-dev-cli.sh`: CLI script for basic management of test containers (start, stop, exec as root, etc.).

## Prerequisites

-   Docker
-   Docker Compose

## Usage

### 1. Build the Base Image

Navigate to `Environments/ubuntu-base/` and run:

```bash
./1-build.sh
```
This will build the image using settings from `.env` and `docker-compose.yaml`.

### 2. Run a Test Container (Optional)

You can run an instance of this base image for testing or inspection:

```bash
./2-dev-cli.sh start
./2-dev-cli.sh status

# Execute a shell inside the running container (as root)
./2-dev-cli.sh exec
# or specific command
./2-dev-cli.sh exec systemctl status

# View logs (systemd journal)
./2-dev-cli.sh logs

# Stop and remove
./2-dev-cli.sh stop
./2-dev-cli.sh rm
```

### 3. Use as a Base for Other Dockerfiles

The primary use case is to reference this image in other Dockerfiles:

```dockerfile
ARG BASE_IMAGE_REPO=${UBUNTU_BASE_SYSTEMD_IMAGE_REPO:-shuai/ubuntu-base-systemd}
ARG BASE_IMAGE_TAG=${UBUNTU_BASE_SYSTEMD_IMAGE_TAG:-noble}
FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG}

# Now, add your specific user, tools, SSH, services, etc.
# For example, using unified-common-setup.sh:
# ARG SETUP_USER=myuser
# ARG USER_PASSWORD=mypassword
# COPY ../../common/docker-setup-scripts/unified-common-setup.sh /tmp/
# RUN bash /tmp/unified-common-setup.sh && rm /tmp/unified-common-setup.sh

# ... rest of your Dockerfile ...
```

## Customization during Build

The `Dockerfile` accepts the following build arguments (passed via `docker-compose.yaml` from shell or `.env`):
-   `LANG`: e.g., `zh_CN.UTF-8`
-   `TERM`: e.g., `xterm-256color`
-   `http_proxy`, `https_proxy`, `no_proxy`: For environments requiring proxy to access internet.

These can be set in the `Environments/ubuntu-base/.env` file or passed when running `./1-build.sh` if the shell environment has them set. 