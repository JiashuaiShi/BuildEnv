# Conda Bio Packages Toolkit

This component provides a Dockerized toolkit containing a collection of bioinformatics tools installed via Conda. It is based on the `biocontainers/biocontainers` base image.

## Overview

-   **Image Name (from .env):** `${BIO_CONDABIOPKGS_IMAGE_REPO}:${BIO_CONDABIOPKGS_IMAGE_TAG}`
-   **Purpose:** Provides a ready-to-use environment with common bioinformatics software for analysis tasks.
-   **Management:** Uses `1-build.sh` to build the image and `2-dev-cli.sh` to manage and run tools.

## Files

-   `Dockerfile`: Defines the image, primarily installing packages using Conda.
-   `docker-compose.yaml`: Configures how to run the toolkit, primarily for defining volumes and environment for `docker-compose run` or `docker-compose exec`.
-   `.env`: Contains environment variables for image name, tag, and container name. (A `.env.example` should be provided if this were a template).
-   `1-build.sh`: Script to build the Docker image.
-   `2-dev-cli.sh`: CLI script to manage the toolkit (start, stop, run tools, remove image, etc.).

## Prerequisites

-   Docker
-   Docker Compose

## Usage

1.  **Configure Environment (Optional):**
    Copy `.env.example` to `.env` (if an example is provided) and customize variables like image repository/tag if needed.
    For this component, the default `.env` is usually sufficient.

2.  **Build the Image:**
    ```bash
    ./1-build.sh
    ```

3.  **Run Tools:**
    The `2-dev-cli.sh` script provides convenient ways to run tools. Volumes defined in `docker-compose.yaml` will be mounted.

    *   **Run a specific tool (creates a transient container):**
        ```bash
        ./2-dev-cli.sh run <your_tool_command> [args...]
        # Example:
        # ./2-dev-cli.sh run bwa index /data/my_reference.fasta
        # (Assumes your data is accessible via mounted volumes, e.g., in /data)
        ```

    *   **Open an interactive shell (bash) in a new transient container:**
        ```bash
        ./2-dev-cli.sh exec
        ```
        Inside the shell, you can directly run the installed bioinfo tools.

    *   **Start a long-running service container (optional, for repeated execs):**
        If you prefer to `exec` into a persistent (but idle) container:
        ```bash
        ./2-dev-cli.sh start
        # Then, to enter the running container:
        # docker-compose exec conda-bio-pkgs bash 
        # or, more generally, find the container ID/name with './2-dev-cli.sh status' and use 'docker exec -it <id> bash'
        ```
        Stop it with `./2-dev-cli.sh stop` and remove with `./2-dev-cli.sh rm`.

## Installed Tools (Examples - see Dockerfile for actual list)

Consult the `Dockerfile` for the definitive list of installed packages. This typically includes tools like:
-   bwa
-   samtools
-   bedtools
-   bowtie2
-   picard
-   gatk4

## Customization

-   **Add/Remove Tools:** Modify the `conda install -y ...` line in the `Dockerfile` and rebuild the image using `./1-build.sh`.
-   **Change Image Name/Tag:** Modify the `BIO_CONDABIOPKGS_IMAGE_REPO` and `BIO_CONDABIOPKGS_IMAGE_TAG` variables in the `.env` file and rebuild. 