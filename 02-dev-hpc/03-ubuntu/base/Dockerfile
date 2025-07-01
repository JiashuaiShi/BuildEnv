#
# Ubuntu 基础镜像 - 用于通用开发
#
# 功能:
#   此 Dockerfile 构建一个最小化的基础开发环境，包含一个非 root 用户、
#   SSH 访问能力和由 Supervisor 管理的基础工具。
#

# --- 基础镜像 ---
# 使用官方的 Ubuntu 镜像，版本通过构建参数指定，默认为 24.04
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于开发的基础镜像，基于Ubuntu，包含用户设置和SSH服务。"

# --- 环境变量 ---
# 设置为非交互式，避免 apt-get 等命令在构建过程中挂起等待用户输入
ENV DEBIAN_FRONTEND=noninteractive \
    # 设置时区
    TZ=Asia/Shanghai \
    # 设置容器的默认语言环境，避免乱码问题
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# --- 构建参数 ---
# 定义将要创建的非 root 用户的用户名、密码、UID 和 GID。
# 示例: docker build --build-arg DEV_PASSWORD=your_pass -t ubuntu-base .
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=change_this_password
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- 软件包安装 ---
# 将所有 apt 操作合并到单个 RUN 层中，以优化镜像大小
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # 基础工具
    sudo \
    ca-certificates \
    wget \
    curl \
    gnupg \
    zsh \
    # SSH 和进程管理
    openssh-server \
    supervisor \
    # 设置时区并清理
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    # 清理 apt 缓存以减小镜像体积
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 配置与用户设置 ---
# 复制配置文件和统一用户设置脚本
COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# 执行用户设置脚本，然后生成 SSH 主机密钥
RUN chmod +x /tmp/unified-user-setup.sh && \
    # 调用脚本创建用户
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    # 删除临时脚本
    rm /tmp/unified-user-setup.sh && \
    # 生成 SSH 服务所需的主机密钥
    ssh-keygen -A && \
    # 确保 sshd 的运行目录存在
    mkdir -p /var/run/sshd

# --- 端口与入口点 ---
# 暴露 SSH 服务的默认端口 22
EXPOSE 22

# 使用 supervisord 启动和管理 sshd 服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
