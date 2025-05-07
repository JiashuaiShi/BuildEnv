# Dockerfile for Combined Diversity, Differential Abundance Analysis and Report Generation
FROM rocker/r-ver:4.1.0

# --- ARGs for build-time configuration ---
ARG LANG=C.UTF-8
ARG TERM=xterm-256color
ARG http_proxy
ARG https_proxy
ARG no_proxy

# Set environment variables, including for R to pick up proxies
ENV LANG=${LANG} \
    LC_ALL=${LANG} \
    TERM=${TERM} \
    HTTP_PROXY=${http_proxy} \
    HTTPS_PROXY=${https_proxy} \
    NO_PROXY=${no_proxy}

# Install R packages
# R will typically use HTTP_PROXY/HTTPS_PROXY from environment for downloads
RUN R -e "install.packages(c('vegan', 'ggplot2', 'DESeq2', 'edgeR', 'rmarkdown', 'knitr'), repos='http://cran.rstudio.com/')"

# Copy analysis scripts from the build context (R-analysis/scripts/)
# These will be at /scripts/ in the image.
COPY scripts/ /scripts/

# Set working directory (optional, but can be useful)
WORKDIR /data

# Set the entrypoint (will be overridden in WDL)
ENTRYPOINT ["Rscript"]
