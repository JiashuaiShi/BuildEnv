#!/bin/bash
# Top-level CLI for running tools in the metagenomics-tools suite

# Get the directory of this script (metagenomics-tools/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# Load .env file from this directory
if [ -f "${ENV_FILE}" ]; then
    export $(grep -v '^#' "${ENV_FILE}" | xargs)
else
    echo "Warning: Top-level ${ENV_FILE} not found."
fi

# Define expected image names (these should align with .env and docker-compose.yaml)
KRAKEN2_IMG="${KRAKEN2_IMAGE_REPO:-my-repo/kraken2-tool}:${KRAKEN2_IMAGE_TAG:-2.1.3}"
KRONA_IMG="${KRONA_IMAGE_REPO:-my-repo/krona-tool}:${KRONA_IMAGE_TAG:-2.8.1}"
R_ANALYSIS_IMG="${R_ANALYSIS_IMAGE_REPO:-my-repo/r-analysis-tool}:${R_ANALYSIS_IMAGE_TAG:-latest}"

# Ensure we are in the script's directory for docker-compose context
cd "${SCRIPT_DIR}" || exit 1

# --- Helper Functions ---
check_image() {
    local image_name="$1"
    if ! docker image inspect "${image_name}" &> /dev/null; then
        echo "Image '${image_name}' not found."
        echo "Please build it first using ./1-build-all.sh (or the specific sub-component's ./1-build.sh)"
        exit 1
    fi
}

# --- Command Definitions ---
run_kraken2() {
    check_image "${KRAKEN2_IMG}"
    echo "Running Kraken2 via top-level docker-compose..."
    echo "Example: $0 run_kraken2 --db /kraken2-db/standard --threads 4 /data/input.fastq > /data/output.kraken"
    echo "(Ensure pipeline_data and kraken2_db are correctly mounted as per docker-compose.yaml)"
    if [ -z "$1" ]; then
        docker-compose run --rm kraken2 --help
        exit 0
    fi
    docker-compose run --rm kraken2 "$@"
}

run_krona() {
    check_image "${KRONA_IMG}"
    echo "Running Krona (ktImportTaxonomy) via top-level docker-compose..."
    echo "Example: $0 run_krona -o /output/my_report.html /data/kraken_output.kraken"
    echo "(Ensure pipeline_data is readable at /data and pipeline_output/krona_reports is writable at /output)"
    if [ -z "$1" ]; then
        docker-compose run --rm krona
        exit 0
    fi
    docker-compose run --rm krona "$@"
}

run_r_analysis() {
    check_image "${R_ANALYSIS_IMG}"
    echo "Running R-analysis script via top-level docker-compose..."
    echo "Example: $0 run_r_analysis /scripts/your_script.R --input /data/some_data.txt --out /reports/my_r_report.html"
    echo "(Ensure pipeline_data is at /data, R-analysis/scripts are at /scripts, pipeline_output/r_reports is at /reports)"
    if [ -z "$1" ]; then
        echo "Please specify the R script to run (e.g., /scripts/your_script.R) and its arguments."
        # To list scripts in image (if copied and not only mounted):
        # docker-compose run --rm r-analysis ls /scripts
        exit 1
    fi
    docker-compose run --rm r-analysis Rscript "$@"
}

print_help() {
    echo "Usage: $0 <command> [tool_specific_arguments...]"
    echo "CLI for the metagenomics-tools suite."
    echo "Ensure images are built with ./1-build-all.sh before running."
    echo "Make sure ./pipeline_data, ./pipeline_output, and any database directories are set up and mounted correctly in docker-compose.yaml."
    echo ""
    echo "Commands:
      run_kraken2 <args>    Run Kraken2 with specified arguments.
      run_krona <args>      Run Krona's ktImportTaxonomy with specified arguments.
      run_r_analysis <script_path_in_container> [args...]
                            Run an R script for analysis.
      build                 (Alias for ./1-build-all.sh) Build/rebuild all tool images.
      ps                    Show status of any running service containers (if any are long-running).
      down                  Stop and remove any containers started by this compose file.
      help                  Show this help message."
}

# --- Main Command Logic ---
COMMAND=$1
shift || true

case "${COMMAND}" in
    run_kraken2)
        run_kraken2 "$@"
        ;;
    run_krona)
        run_krona "$@"
        ;;
    run_r_analysis)
        run_r_analysis "$@"
        ;;
    build)
        "${SCRIPT_DIR}/1-build-all.sh"
        ;;
    ps)
        docker-compose ps
        ;;
    down)
        docker-compose down --remove-orphans
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo "Error: Unknown command '${COMMAND}'."
        print_help
        exit 1
        ;;
esac
exit 0 