#
# Web 开发基础镜像
#
# 功能:
#   此 Dockerfile 构建一个包含 Node.js, Python, 一个非 root 用户,
#   SSH 访问能力和基础工具的 Web 开发基础环境。
#

# --- 基础镜像 ---
# 使用官方的 Ubuntu 镜像，版本通过构建参数指定，默认为 24.04
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于 Web 开发的基础镜像，基于 Ubuntu，预装了 Node.js, Python, 并配置了用户和 SSH。"

# --- 环境变量 ---
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    # 指定 Node.js 的主版本
    NODE_VERSION=20

# --- 构建参数 ---
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=change_this_password
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- 软件包安装 ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # 基础工具
    sudo \
    ca-certificates \
    wget \
    curl \
    gnupg \
    zsh \
    # Python 环境
    python3 \
    python3-pip \
    # SSH 和进程管理
    openssh-server \
    supervisor \
    # 从 NodeSource 安装 Node.js
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    # 设置时区并清理
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 配置与用户设置 ---
# 注意：对于Ubuntu, supervisor的配置文件路径是 /etc/supervisor/supervisord.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# 执行用户设置脚本，然后生成 SSH 主机密钥
RUN chmod +x /tmp/unified-user-setup.sh && \
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    rm /tmp/unified-user-setup.sh && \
    ssh-keygen -A && \
    mkdir -p /var/run/sshd

# --- 端口与入口点 ---
# 暴露 SSH 和常见的 Web 开发端口
EXPOSE 22 3000 8000 8080

# 使用 supervisord 启动和管理 sshd 服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
