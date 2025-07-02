#
# NAS 基础镜像 - 用于开发与管理 (已优化)
#
# 功能:
#   此 Dockerfile 在 AlmaLinux 基础上，构建一个高效、安全的 NAS 基础环境，
#   包含 Samba, NFS, 一个标准非 root 用户, SSH 访问能力和基础服务。
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

# --- 核心软件包安装与清理 ---
# 将所有安装和清理步骤合并到一个 RUN 指令中，以减少镜像层数和体积。
RUN dnf -y update && \
    # 1. 安装核心依赖包 (按字母顺序排列)
    dnf -y install \
        curl \
        nfs-utils \
        openssh-server \
        python3-pip \
        samba \
        sudo \
        wget \
        zsh \
    # 2. 使用 pip 安装 supervisor 用于进程管理
    && pip3 install supervisor \
    # 3. 清理 dnf 缓存，这是减小镜像体积的关键步骤
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- 配置文件复制 ---
# 将配置文件和脚本复制到镜像中。
# 将此步骤与安装分离，可以更好地利用 Docker 缓存。
COPY supervisord.conf /etc/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY ../../scripts/unified-user-setup.sh /tmp/unified-user-setup.sh

# --- 用户创建与最终配置 ---
# 执行用户设置，并完成最后的系统配置。
RUN \
    # 1. 赋予脚本执行权限
    chmod +x /tmp/unified-user-setup.sh && \
    # 2. 调用脚本创建用户、设置密码并配置 sudo (已修正参数)
    /tmp/unified-user-setup.sh "${DEV_USER}" "${DEV_PASSWORD}" "${USER_UID}" "${DEV_GROUP}" "${GROUP_GID}" && \
    # 3. 删除不再需要的临时脚本
    rm /tmp/unified-user-setup.sh && \
    # 4. 生成 SSH 服务所需的主机密钥
    ssh-keygen -A && \
    # 5. 创建 sshd 运行时目录，确保服务能正常启动
    mkdir -p /var/run/sshd

# --- 端口与入口点 ---
# 22: SSH, 139/445: Samba, 111/2049: NFS
EXPOSE 22 139 445 111 2049

# 使用 supervisord 启动和管理 sshd 服务
CMD ["/usr/bin/python3", "-m", "supervisor.supervisord", "-c", "/etc/supervisord.conf"]
