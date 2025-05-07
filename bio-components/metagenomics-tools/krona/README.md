# Krona Tool Component (within Metagenomics Tools)

This component provides a Dockerized version of Krona Tools, specifically for creating Krona charts.

## Overview

-   **Tool:** Krona Tools (primarily `ktImportTaxonomy`)
-   **Version (in Dockerfile):** 2.8.1
-   **Base Image:** `biocontainers/biocontainers:v1.2.0_cv2`
-   **Purpose:** Encapsulates Krona Tools for generating interactive charts from taxonomy data.
-   **Default `ENTRYPOINT`:** `ktImportTaxonomy`

## Files within `BioComponents/metagenomics-tools/krona/`

-   `Dockerfile`: Defines the image, installs Krona Tools via Conda.
-   `docker-compose.yaml`: Used by `1-build.sh` for building and by `2-dev-cli.sh` for running the tool. Can be customized with volume mounts for standalone use.
-   `.env`: Defines image repository, tag, and container name for this tool.
-   `1-build.sh`: Script to build the Krona Docker image.
-   `2-dev-cli.sh`: CLI script to run `ktImportTaxonomy` commands or get a shell.

## Prerequisites

-   Docker
-   Docker Compose

## Usage (Standalone)

1.  **Navigate to this directory:**
    ```bash
    cd BioComponents/metagenomics-tools/krona/
    ```

2.  **Configure `.env` (Optional):**
    Defaults are usually sufficient for local use.

3.  **Build the Image:**
    ```bash
    ./1-build.sh
    ```

4.  **Run Krona Commands (ktImportTaxonomy):**
    Use the `2-dev-cli.sh` script.
    *   **Run `ktImportTaxonomy`:**
        The `run` command passes arguments directly to `ktImportTaxonomy`.
        ```bash
        # Example: Get help for ktImportTaxonomy (runs entrypoint with no args, which might show help)
        ./2-dev-cli.sh run 

        # Example: Generate a Krona chart
        # (Assumes input.taxonomy is in a mounted volume, e.g., /data if configured)
        # ./2-dev-cli.sh run input.taxonomy -o output.krona.html
        ```
        For actual runs, you'll need input files. The `WORKDIR` is `/data/`, a common mount point.

    *   **Open an interactive shell (bash):**
        ```bash
        ./2-dev-cli.sh exec
        ```

## Integration with Metagenomics Tools Suite

This `krona` component is designed to be orchestrated by the parent `BioComponents/metagenomics-tools/` directory. The top-level `docker-compose.yaml` will manage running this service, potentially linking its input/output with other services like Kraken2.

-   The image built by `krona/1-build.sh` (`my-repo/krona-tool:2.8.1` by default) will be used by the main `docker-compose.yaml`. 