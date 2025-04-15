# FROM mcr.microsoft.com/devcontainers/base:ubuntu
FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04

# 设置维护者信息
LABEL maintainer="shijiashuai" description="VS Code C++ Dev Container (Ubuntu 22.04 based)"

# Use ARG for build-time proxy
ARG http_proxy
ARG https_proxy
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV DEBIAN_FRONTEND=noninteractive

# --- Run Common User Setup Script ---
# Installs: sudo, openssh-server, zsh, supervisor, user/group, basic ssh/supervisor conf
# Note: Base image already provides some tools like zsh, sudo. Script handles potential conflicts.
COPY ../../scripts/common-user-setup.sh /tmp/
RUN chmod +x /tmp/common-user-setup.sh && \
    bash /tmp/common-user-setup.sh && \
    rm /tmp/common-user-setup.sh

# --- Install Environment Specific Tools ---
# Install libs needed by samtools and potentially other tools
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    xz-utils \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 \
    && tar -xvf samtools-1.18.tar.bz2 \
    && cd samtools-1.18 \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && cd .. && rm -r samtools-1.18 samtools-1.18.tar.bz2

# 安装 bwa ( uncomment if needed )
# RUN apt-get update && apt-get install -y --no-install-recommends bwa && apt-get clean && rm -rf /var/lib/apt/lists/*
# Or build from source if specific version needed:
# RUN wget https://github.com/lh3/bwa/releases/download/v0.7.17/bwa-0.7.17.tar.bz2 \
#     && tar -xvf bwa-0.7.17.tar.bz2 \
#     && cd bwa-0.7.17 \
#     && make \
#     && mv bwa /usr/local/bin/ \
#     && cd .. && rm -r bwa-0.7.17 bwa-0.7.17.tar.bz2

# --- Configure Supervisor ---
# Create a simple supervisord config to start sshd
RUN echo '[supervisord]\nnodaemon=true\nuser=root\n' > /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\nuser=root\n' >> /etc/supervisor/conf.d/supervisord.conf && \
    chmod 644 /etc/supervisor/conf.d/supervisord.conf

# 切换到普通用户
USER shijiashuai
WORKDIR /home/shijiashuai # Or /workspace depending on preference

# 安装 oh-my-zsh
RUN rm -rf /home/shijiashuai/.oh-my-zsh && \
    (git clone https://gitee.com/mirrors/oh-my-zsh.git /home/shijiashuai/.oh-my-zsh || \
     git clone https://github.com/ohmyzsh/ohmyzsh.git /home/shijiashuai/.oh-my-zsh) && \
    cp /home/shijiashuai/.oh-my-zsh/templates/zshrc.zsh-template /home/shijiashuai/.zshrc && \
    chown -R shijiashuai:lush-dev /home/shijiashuai/.oh-my-zsh /home/shijiashuai/.zshrc

# 清理代理环境变量
USER root
ENV http_proxy=""
ENV https_proxy=""

# 暴露SSH端口
EXPOSE 22

# 声明 VOLUME (User dirs created by common script)
VOLUME ["/data", "/data1", "/workspace"]

# 设置容器启动命令 - Use Supervisor
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]