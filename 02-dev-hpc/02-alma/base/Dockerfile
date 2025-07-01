#
# AlmaLinux 基础镜像 - 用于 HPC 开发
#
# 功能:
#   此 Dockerfile 构建一个基础开发环境，包含一个非 root 用户、
#   SSH 访问能力和由 Supervisor 管理的基础工具。
#

# --- 基础镜像 ---
# 使用官方的 AlmaLinux 镜像，版本通过构建参数指定，默认为 9
ARG ALMA_VERSION=9
FROM almalinux:${ALMA_VERSION}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于HPC开发的基础镜像，基于AlmaLinux，包含用户设置和SSH服务。"

# --- 环境变量 ---
# 设置容器的默认语言环境，避免乱码问题
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# --- 构建参数 ---
# 定义将要创建的非 root 用户的用户名、密码、UID 和 GID。
# 这些参数可以在 `docker build` 命令中通过 `--build-arg` 覆盖。
# 示例: docker build --build-arg DEV_PASSWORD=your_pass -t alma-base .
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=change_this_password # 默认密码，强烈建议在构建时修改
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- 软件包安装 ---
# 安装开发环境所必需的核心软件包
RUN dnf -y update && dnf -y install \
    sudo \
    zsh \
    openssh-server \
    python3-pip \
    wget \
    curl \
    gnupg \
    ca-certificates \
    # 使用 pip 安装 supervisor 用于进程管理
    && pip3 install supervisor \
    # 清理 dnf 缓存以减小镜像体积
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- 配置与用户设置 ---
# 复制配置文件和统一用户设置脚本到镜像中
COPY supervisord.conf /etc/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# 执行用户设置脚本，然后生成 SSH 主机密钥
RUN chmod +x /tmp/unified-user-setup.sh && \
    # 调用脚本创建用户、设置密码并配置 sudo
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    # 删除临时脚本
    rm /tmp/unified-user-setup.sh && \
    # 生成 SSH 服务所需的主机密钥
    ssh-keygen -A

# --- 端口与入口点 ---
# 暴露 SSH 服务的默认端口 22
EXPOSE 22

# 使用 supervisord 启动和管理 sshd 服务
# 这是容器的主进程
CMD ["/usr/bin/python3", "-m", "supervisor.supervisord", "-c", "/etc/supervisord.conf"]
