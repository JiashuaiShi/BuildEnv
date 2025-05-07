# Metagenomics Tools Suite

This directory orchestrates a suite of bioinformatics tools for metagenomics analysis, including Kraken2, Krona, and R-based analysis scripts.

## Overview

The suite is structured with a top-level `docker-compose.yaml` that defines services for each tool. Each tool also resides in its own subdirectory (`kraken2/`, `krona/`, `R-analysis/`) containing its specific Dockerfile, local build/run scripts, and configuration (`.env`).

**Workflow Idea:**
1.  Raw sequence data (e.g., FASTQ files) are processed by Kraken2 for taxonomic classification.
2.  Kraken2 output is visualized using Krona.
3.  Kraken2 output (or other data) is used for statistical analysis and report generation with R scripts.

## Directory Structure (`BioComponents/metagenomics-tools/`)

-   `docker-compose.yaml`: Top-level file to build and run the orchestrated services.
-   `.env`: Top-level environment file (mainly for defining expected image names and optional shared paths).
-   `1-build-all.sh`: Script to build Docker images for all tools in the suite.
-   `2-cli.sh`: Command-line interface to run tools/pipeline steps via the top-level `docker-compose.yaml`.
-   `kraken2/`: Subdirectory for the Kraken2 tool.
    -   `Dockerfile`, `docker-compose.yaml`, `.env`, `1-build.sh`, `2-dev-cli.sh`, `README.md`
-   `krona/`: Subdirectory for the Krona tool.
    -   `Dockerfile`, `docker-compose.yaml`, `.env`, `1-build.sh`, `2-dev-cli.sh`, `README.md`
-   `R-analysis/`: Subdirectory for R-based analysis.
    -   `Dockerfile`, `docker-compose.yaml`, `.env`, `1-build.sh`, `2-dev-cli.sh`, `README.md`
    -   `scripts/`: Contains R scripts used by this component.
-   `pipeline_data/` (Recommended): Create this directory locally to store input data, intermediate files, and databases shared between tools. It's typically mounted to `/data` in containers.
-   `pipeline_output/` (Recommended): Create this directory locally to store final reports and outputs.
    -   `krona_reports/`
    -   `r_reports/`
-   `kraken2_db_example/` (Recommended for Kraken2): Create or link your Kraken2 database here. The top-level `docker-compose.yaml` mounts this to `/kraken2-db` in the Kraken2 container by default (configurable via `HOST_KRAKEN_DB_DIR` in `.env`).

## Prerequisites

-   Docker
-   Docker Compose
-   Ensure sub-component `.env` files are configured (especially passwords if any were introduced, though these tools typically don't require them for basic operation).

## Setup and Usage

1.  **Navigate to this directory:**
    ```bash
    cd BioComponents/metagenomics-tools/
    ```

2.  **Configure Top-Level `.env` (Optional but Recommended):**
    -   Review and edit `.env` in this directory.
    -   Set `HOST_KRAKEN_DB_DIR` if your Kraken2 database is not at `./kraken2_db_example`.
    -   You can also override default image names/tags here if you've changed them in sub-component `.env` files and want the top-level compose to use those.

3.  **Build All Tool Images:**
    This uses the top-level `docker-compose.yaml` which in turn uses the Dockerfiles in subdirectories.
    ```bash
    ./1-build-all.sh
    # or ./2-cli.sh build
    ```
    Alternatively, you can build each sub-component image individually by going into its directory and running its local `./1-build.sh`.

4.  **Prepare Data and Databases:**
    -   Place your input sequence files (e.g., FASTQ) into `./pipeline_data/`.
    -   Ensure your Kraken2 database is accessible at the path specified by `HOST_KRAKEN_DB_DIR` (or default `./kraken2_db_example/`).

5.  **Run Tools/Pipeline Steps using `./2-cli.sh`:**

    *   **Run Kraken2:**
        The output will typically go to `/data` inside the container (which is `./pipeline_data/` on the host).
        ```bash
        # Example: Get Kraken2 help
        ./2-cli.sh run_kraken2 --help 

        # Example: Classify sequences
        ./2-cli.sh run_kraken2 --db /kraken2-db --threads 4 /data/my_reads.fastq --output /data/my_reads.kraken --report /data/my_reads.kreport
        ```

    *   **Run Krona:**
        Assumes Kraken2 output is in `/data` (e.g., `/data/my_reads.kraken`). Output HTML goes to `/output` (host: `./pipeline_output/krona_reports/`).
        ```bash
        # Example: Generate Krona report from Kraken2 output
        ./2-cli.sh run_krona -o /output/my_reads_krona.html /data/my_reads.kraken
        ```

    *   **Run R Analysis:**
        Assumes input data is in `/data` and R scripts are in `/scripts` (host: `./R-analysis/scripts/`). Output goes to `/reports` (host: `./pipeline_output/r_reports/`).
        ```bash
        # Example: Run an R script
        ./2-cli.sh run_r_analysis /scripts/generate_report.R --input_table /data/my_reads.kreport --output_file /reports/final_metagenomics_report.html
        ```

    *   **Other commands:**
        ```bash
        ./2-cli.sh ps     # See status of running services (if any were started detached)
        ./2-cli.sh down   # Stop and remove any containers started by this suite's compose file
        ./2-cli.sh help   # Display help
        ```

## Customization

-   **Tool Versions:** Modify the `Dockerfile` within each sub-component (`kraken2/`, `krona/`, `R-analysis/`) to change tool versions or dependencies. Rebuild with `./1-build-all.sh` or the sub-component's `1-build.sh`.
-   **R Scripts:** Add or modify R scripts in `BioComponents/metagenomics-tools/R-analysis/scripts/`.
-   **Pipeline Logic:** Adjust commands and volume mounts in the top-level `BioComponents/metagenomics-tools/docker-compose.yaml` to change how data flows between tools or to add new tools.
-   **Volume Mounts:** The `./pipeline_data`, `./pipeline_output`, and database paths in the top-level `docker-compose.yaml` are examples. Adjust them to your actual data locations. 