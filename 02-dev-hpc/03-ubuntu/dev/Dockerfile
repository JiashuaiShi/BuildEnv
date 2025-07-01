#
# Ubuntu 开发镜像 - 用于 HPC
#
# 功能:
#   此 Dockerfile 继承自 ubuntu-base 基础镜像，
#   并安装了针对 C++/Java HPC 开发的工具链及 Oh My Zsh。
#

# --- 基础镜像 ---
# 通过构建参数指定基础镜像和开发用户名
ARG BASE_IMAGE=ubuntu-base:latest
ARG DEV_USER=shijiashuai
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于HPC开发的Ubuntu镜像，预装了C++/Java工具链和常用开发工具。"

# --- 安装开发工具 ---
# 切换到 root 用户以安装系统级软件包
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    # C++ 工具链
    g++ \
    clang \
    cmake \
    gdb \
    valgrind \
    # Java 工具链
    openjdk-17-jdk \
    maven \
    # 常用工具
    git \
    vim \
    htop \
    # 清理 apt 缓存
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 用户级配置 (Oh My Zsh) ---
# 切换到开发用户来执行用户级别的安装
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

# 安装 Oh My Zsh 及其常用插件 (自动建议、语法高亮)
# `|| true` 确保即使安装失败（例如，在已安装的情况下），构建也不会中断
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    # 在 .zshrc 中自动启用插件
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# --- 最终设置 ---
# 切换回 root 用户。容器将由 Docker 以 root 身份启动，
# 然后 Supervisor 会管理具体服务。用户可以通过 SSH 以 DEV_USER 身份连接。
# 将默认工作目录设置为 /workspace
USER root
WORKDIR /workspace

# CMD 指令从基础镜像继承
