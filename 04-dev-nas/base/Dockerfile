#
# NAS 基础镜像 - 用于开发与管理
#
# 功能:
#   此 Dockerfile 在 AlmaLinux 基础上，构建一个包含 Samba, NFS 工具,
#   一个非 root 用户, SSH 访问能力和基础工具的 NAS 基础环境。
#

# --- 基础镜像 ---
ARG ALMA_VERSION=9
FROM almalinux:${ALMA_VERSION}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于 NAS 的基础镜像，预装了 Samba, NFS, 并配置了用户和 SSH。"

# --- 环境变量 ---
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# --- 构建参数 ---
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=change_this_password
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- 软件包安装 ---
RUN dnf -y update && dnf -y install \
    # 基础工具
    sudo \
    zsh \
    wget \
    curl \
    # NAS 相关工具
    samba \
    nfs-utils \
    # SSH 和进程管理
    openssh-server \
    python3-pip \
    && pip3 install supervisor \
    # 清理
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- 配置与用户设置 ---
# 注意：对于 AlmaLinux, supervisor 的主配置文件是 /etc/supervisord.conf
COPY supervisord.conf /etc/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# 执行用户设置脚本，然后生成 SSH 主机密钥
RUN chmod +x /tmp/unified-user-setup.sh && \
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    rm /tmp/unified-user-setup.sh && \
    ssh-keygen -A && \
    mkdir -p /var/run/sshd

# --- 端口与入口点 ---
# 22: SSH, 139/445: Samba, 111/2049: NFS
EXPOSE 22 139 445 111 2049

# 使用 supervisord 启动和管理 sshd 服务
CMD ["/usr/bin/python3", "-m", "supervisor.supervisord", "-c", "/etc/supervisord.conf"]
