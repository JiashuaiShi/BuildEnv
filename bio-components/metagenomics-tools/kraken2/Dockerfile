# Use the Ubuntu 24.04 base image
FROM ubuntu:24.04

# --- ARGs for build-time configuration ---
ARG LANG=C.UTF-8
ARG TERM=xterm-256color
ARG http_proxy
ARG https_proxy
ARG no_proxy

# Labels
LABEL base.image="ubuntu:24.04" \
      dockerfile.version="1" \
      software="Kraken2" \
      software.version="2.1.3" \
      description="Taxonomic sequence classifier" \
      website="https://github.com/DerrickWood/kraken2" \
      license="https://github.com/DerrickWood/kraken2/blob/master/LICENSE" \
      maintainer="Curtis Kapsak" \
      maintainer.email="kapsakcj@gmail.com"

# Set the Kraken2 version
ENV K2VER="2.1.3"

# Set environment variables
ENV PATH="/kraken2-${K2VER}:$PATH" \
    LC_ALL=${LANG} \
    LANG=${LANG} \
    TERM=${TERM}

# Install dependencies and Kraken2
# Use build-time ARGs for proxies if set
RUN echo "Acquire::http::Proxy \"${http_proxy}\";" > /etc/apt/apt.conf.d/80proxy && \
    echo "Acquire::https::Proxy \"${https_proxy}\";" >> /etc/apt/apt.conf.d/80proxy && \
    apt-get update && apt-get -y --no-install-recommends install \
        wget \
        ca-certificates \
        zlib1g-dev \
        make \
        g++ \
        rsync \
        cpanminus && \
    rm -rf /var/lib/apt/lists/* && apt-get autoclean && \
    cpanm Getopt::Std && \
    # Configure wget to use proxies if set
    ( [ -n "${http_proxy}" ] && echo "http_proxy = ${http_proxy}" >> /etc/wgetrc || true ) && \
    ( [ -n "${https_proxy}" ] && echo "https_proxy = ${https_proxy}" >> /etc/wgetrc || true ) && \
    ( [ -n "${no_proxy}" ] && echo "no_proxy = ${no_proxy}" >> /etc/wgetrc || true ) && \
    wget https://github.com/DerrickWood/kraken2/archive/v${K2VER}.tar.gz && \
    tar -xzf v${K2VER}.tar.gz && \
    rm -rf v${K2VER}.tar.gz && \
    cd kraken2-${K2VER} && \
    ./install_kraken2.sh . && \
    mkdir /data /kraken2-db && \
    # Clean up proxy conf
    rm -f /etc/apt/apt.conf.d/80proxy /etc/wgetrc

# Set the default command to the kraken2 executable
CMD ["kraken2"]
