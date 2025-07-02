#
# Web 开发基础镜像 (已优化)
#
# 功能:
#   此 Dockerfile 构建一个高效、安全的基础 Web 开发环境，基于 Ubuntu，
#   预装了 Node.js, Python, 并配置了标准非 root 用户和 SSH 访问。
#

# --- 基础镜像 ---
# 使用官方的 Ubuntu 镜像，版本通过构建参数指定，默认为 24.04
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于 Web 开发的基础镜像，基于 Ubuntu，预装了 Node.js, Python, 并配置了用户和 SSH。"

# --- 环境变量 ---
# 设置为非交互式，避免 apt-get 等命令在构建过程中挂起等待用户输入
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    # 指定 Node.js 的主版本
    NODE_VERSION=20

# --- 构建参数 ---
# 定义将要创建的非 root 用户的用户名、密码、UID 和 GID。
ARG DEV_USER=shijiashuai
ARG DEV_PASSWORD=change_this_password
ARG USER_UID=2034
ARG DEV_GROUP=lush-dev
ARG GROUP_GID=2000

# --- 核心软件包安装与清理 ---
# 将所有安装和清理步骤合并到一个 RUN 指令中，以减少镜像层数和体积。
RUN apt-get update && \
    # 1. 安装基础依赖包 (按字母顺序排列)
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        openssh-server \
        python3 \
        python3-pip \
        sudo \
        supervisor \
        wget \
        zsh \
    # 2. 添加 NodeSource 仓库并安装 Node.js (安全方式)
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    # 3. 设置时区
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    # 4. 清理 apt 缓存，这是减小镜像体积的关键步骤
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- 配置文件复制 ---
# 将配置文件和脚本复制到镜像中。将此步骤与安装分离，可以更好地利用 Docker 缓存。
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
# 暴露 SSH 和常见的 Web 开发端口
EXPOSE 22 3000 8000 8080

# 使用 supervisord 启动和管理 sshd 服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
