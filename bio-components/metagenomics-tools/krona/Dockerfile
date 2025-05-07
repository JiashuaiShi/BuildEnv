# Dockerfile for Krona Visualization
################## BASE IMAGE ######################
FROM biocontainers/biocontainers:v1.2.0_cv2

# --- ARGs for build-time configuration ---
ARG LANG=C.UTF-8
ARG TERM=xterm-256color
ARG http_proxy
ARG https_proxy
ARG no_proxy

################## METADATA ######################
LABEL base_image="biocontainers:v1.2.0_cv2"
LABEL version="1"
LABEL software="krona"
LABEL software.version="2.8.1"
LABEL about.summary="Krona Tools is a set of scripts to create Krona charts from several Bioinformatics tools as well as from text and XML files."
LABEL about.home="https://github.com/marbl/Krona"
LABEL about.documentation="https://github.com/marbl/Krona/wiki"
LABEL about.license_file="https://github.com/marbl/Krona/blob/master/KronaTools/LICENSE.txt"
LABEL about.license="BSD"
LABEL about.tags="General"

################## INSTALLATION ######################
USER root

# Setup proxies for apt and conda
RUN ( [ -n "${http_proxy}" ] && echo "Acquire::http::Proxy \"${http_proxy}\";" > /etc/apt/apt.conf.d/80proxy || true ) && \\
    ( [ -n "${https_proxy}" ] && echo "Acquire::https::Proxy \"${https_proxy}\";" >> /etc/apt/apt.conf.d/80proxy || true ) && \\
    apt-get clean all && \\
    apt-get update && \\
    apt-get install -y apt-utils curl && \\
    # Configure conda proxies
    ( [ -n "${http_proxy}" ] && conda config --set proxy_servers.http ${http_proxy} || true ) && \\
    ( [ -n "${https_proxy}" ] && conda config --set proxy_servers.https ${https_proxy} || true ) && \\
    conda config --set ssl_verify no && \\
    conda install -c bioconda krona=2.8.1 && \\
    # Update taxonomy. It might need internet access, ensure proxies are effective for this script too.
    # If ktUpdateTaxonomy.sh uses wget/curl, it might need explicit proxy vars if not picked from env.
    ( export http_proxy=${http_proxy} https_proxy=${https_proxy} no_proxy=${no_proxy}; ktUpdateTaxonomy.sh ) && \\
    apt-get clean all && \\
    apt-get purge -y --auto-remove apt-utils curl && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \\
    # Clean up proxy conf
    rm -f /etc/apt/apt.conf.d/80proxy && \\
    conda config --remove-key proxy_servers.http || true && \\
    conda config --remove-key proxy_servers.https || true

# Set runtime environment variables
ENV LANG=${LANG} \\
    TERM=${TERM} \\
    LC_ALL=${LANG}

USER biodocker

WORKDIR /data/

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/ktImportTaxonomy"]
