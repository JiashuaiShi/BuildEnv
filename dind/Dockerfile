# Use the official Docker image with dind support
FROM docker:dind

# Install necessary tools, dependencies, and compilers
RUN apk add --no-cache \
    bash \
    curl \
    git \
    python3 \
    py3-pip \
    build-base \
    pkgconfig \  
    python3-dev  # 添加 python3-dev 以支持编译某些 Python 包

# Create and activate a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Update pip, setuptools, and wheel in the virtual environment
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Python packages in the virtual environment
RUN pip install --no-cache-dir \
    biopython \
    numpy \
    pandas \
    scikit-learn

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/2.28.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Set entrypoint
ENTRYPOINT ["dockerd-entrypoint.sh"]

# Start Docker daemon and keep the container running
CMD ["sh", "-c", "while :; do if ! pgrep sleep > /dev/null; then sleep 6h & fi; wait $${!}; done"]