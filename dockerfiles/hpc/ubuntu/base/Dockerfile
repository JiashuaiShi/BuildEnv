#
# Ubuntu 基础镜像 - 用于通用开发 (已优化)
#
# 功能:
#   此 Dockerfile 构建一个高效、安全的基础开发环境，包含一个标准非 root 用户、
#   SSH 访问能力和由 Supervisor 管理的基础服务。
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
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# --- 构建参数 ---
# 定义将要创建的非 root 用户的用户名、密码、UID 和 GID。
# 这些值将由 build.sh 脚本从 .env 文件中读取并注入，此处仅声明
ARG DEV_USER
ARG DEV_PASSWORD
ARG USER_UID
ARG DEV_GROUP
ARG GROUP_GID

# --- 核心软件包安装与清理 ---
# 将所有安装和清理步骤合并到一个 RUN 指令中，以减少镜像层数和体积。
RUN apt-get update && \
    # 1. 安装核心依赖包 (按字母顺序排列以方便维护)
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        openssh-server \
        sudo \
        supervisor \
        wget \
        zsh \
    # 2. 设置时区
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    # 3. 清理 apt 缓存，这是减小镜像体积的关键步骤
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- 配置文件复制 ---
# 将配置文件和脚本复制到镜像中。
# 将此步骤与安装分离，可以更好地利用 Docker 缓存。
# 注意：Ubuntu下supervisor的主配置文件路径是 /etc/supervisor/supervisord.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# --- 用户创建与最终配置 ---
# 执行用户设置，并完成最后的系统配置。
RUN \
    # 1. 赋予脚本执行权限
    chmod +x /tmp/unified-user-setup.sh && \
    # 2. 调用脚本创建用户、设置密码并配置 sudo
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    # 3. 删除不再需要的临时脚本
    rm /tmp/unified-user-setup.sh && \
    # 4. 生成 SSH 服务所需的主机密钥
    ssh-keygen -A && \
    # 5. 创建 sshd 运行时目录，确保服务能正常启动
    mkdir -p /var/run/sshd

# --- 端口与入口点 ---
# 暴露 SSH 服务的默认端口 22
EXPOSE 22

# 使用 supervisord 启动和管理 sshd 服务，这是容器的主进程。
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
