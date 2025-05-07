# Kraken2 Tool Component (within Metagenomics Tools)

This component provides a Dockerized version of Kraken2, a taxonomic sequence classifier.

## Overview

-   **Tool:** Kraken2
-   **Version (in Dockerfile):** 2.1.3 (via `ENV K2VER`)
-   **Base Image:** `ubuntu:24.04`
-   **Purpose:** Encapsulates Kraken2 for use as a standalone tool or as part of the larger `metagenomics-tools` suite.
-   **Default CMD:** `kraken2` (the tool itself)

## Files within `BioComponents/metagenomics-tools/kraken2/`

-   `Dockerfile`: Defines the image, installs Kraken2 and its dependencies.
-   `docker-compose.yaml`: Primarily for building the image via `1-build.sh` and for `2-dev-cli.sh` to run the tool. It can be customized with volume mounts if running standalone.
-   `.env`: Defines image repository, tag, and container name for this specific tool.
-   `1-build.sh`: Script to build the Kraken2 Docker image using its own `docker-compose.yaml`.
-   `2-dev-cli.sh`: CLI script to run Kraken2 commands or get a shell within the tool's environment.

## Prerequisites

-   Docker
-   Docker Compose

## Usage (Standalone)

While this tool is often used via the top-level `metagenomics-tools` orchestrator, you can build and run it standalone:

1.  **Navigate to this directory:**
    ```bash
    cd BioComponents/metagenomics-tools/kraken2/
    ```

2.  **Configure `.env` (Optional):**
    The defaults in `.env` (e.g., for image name) are usually fine for local use.

3.  **Build the Image:**
    ```bash
    ./1-build.sh
    ```

4.  **Run Kraken2 Commands:**
    Use the `2-dev-cli.sh` script.
    *   **Run a specific Kraken2 command:**
        ```bash
        # Example: Get Kraken2 help
        ./2-dev-cli.sh run --help

        # Example: Classify sequences (assuming DB and data are mounted or accessible)
        # You would typically modify the kraken2/docker-compose.yaml to add volume mounts for DBs and data,
        # or rely on the top-level metagenomics-tools/docker-compose.yaml for such configurations.
        # ./2-dev-cli.sh run --db /kraken2-db/mydb reads.fastq --output output.kraken
        ```
        For actual runs, you'll need a Kraken2 database. The Dockerfile creates `/kraken2-db` which is a typical mount point for a database volume.

    *   **Open an interactive shell (bash) in a new Kraken2 container:**
        ```bash
        ./2-dev-cli.sh exec
        ```

## Integration with Metagenomics Tools Suite

This `kraken2` component is designed to be built and orchestrated by the files in the parent `BioComponents/metagenomics-tools/` directory. The top-level `docker-compose.yaml` will define how this `kraken2` service is run, including volume mounts for databases and data, and how it interacts with other services like Krona.

-   The image built by `kraken2/1-build.sh` (`my-repo/kraken2-tool:2.1.3` by default) will be referenced by the top-level `docker-compose.yaml`. 