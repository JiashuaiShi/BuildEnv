# R Analysis Tool Component (within Metagenomics Tools)

This component provides a Dockerized R environment with specific packages for analysis, intended to run R scripts.

## Overview

-   **Tool/Environment:** R with statistical/bioinformatics packages.
-   **Base Image:** `rocker/r-ver:4.1.0`
-   **Key R Packages (in Dockerfile):** `vegan`, `ggplot2`, `DESeq2`, `edgeR`, `rmarkdown`, `knitr`.
-   **Purpose:** Executes R scripts for analysis, particularly those found in its local `scripts/` directory (which are also copied into the image at `/scripts/`).
-   **Default `ENTRYPOINT`:** `Rscript`

## Files within `BioComponents/metagenomics-tools/R-analysis/`

-   `Dockerfile`: Defines the image, installs R and specified R packages. Copies local scripts into `/scripts/` in the image.
-   `docker-compose.yaml`: Configures the service for building via `1-build.sh` and running via `2-dev-cli.sh`. Mounts local `./scripts` to `/scripts` and local `./data` to `/data` by default when used with this compose file.
-   `.env`: Defines image repository, tag, and container name.
-   `1-build.sh`: Script to build the R analysis Docker image.
-   `2-dev-cli.sh`: CLI script to run R scripts or open an R/bash shell.
-   `scripts/` (directory): Contains R scripts (e.g., `diversity_analysis.R`, `differential_abundance_analysis.R`, `generate_report.R` as per original Dockerfile).

## Prerequisites

-   Docker
-   Docker Compose

## Usage (Standalone)

1.  **Navigate to this directory:**
    ```bash
    cd BioComponents/metagenomics-tools/R-analysis/
    ```

2.  **Ensure R scripts are present** in the `scripts/` subdirectory if you intend to use them.

3.  **Build the Image:**
    ```bash
    ./1-build.sh
    ```

4.  **Run R Scripts or Open Shells:**
    Use the `2-dev-cli.sh` script.
    *   **Run an R script:**
        The `run` command passes arguments to `Rscript` (the entrypoint).
        The local `./scripts` directory is mounted to `/scripts` in the container, and `./data` to `/data`.
        ```bash
        # Example: Run a script located in the container at /scripts/your_script.R
        ./2-dev-cli.sh run /scripts/your_script.R --arg1 value1 --input /data/input.txt

        # If your_script.R is in the local ./scripts/ directory:
        # ./2-dev-cli.sh run /scripts/your_script.R ...
        ```

    *   **Open an interactive R console:**
        ```bash
        ./2-dev-cli.sh r_shell
        ```

    *   **Open an interactive bash shell:**
        ```bash
        ./2-dev-cli.sh bash
        ```

## Integration with Metagenomics Tools Suite

This `R-analysis` component is orchestrated by the parent `BioComponents/metagenomics-tools/` setup. The top-level `docker-compose.yaml` will manage this service (likely named `combined_analysis` or `r_analysis` there), providing necessary data volumes and potentially linking its execution in a pipeline with Kraken2 and Krona.

-   The image built by `R-analysis/1-build.sh` will be used.
-   The top-level compose file will handle appropriate volume mounts for data and scripts for the pipeline context. 