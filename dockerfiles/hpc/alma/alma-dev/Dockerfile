#
# AlmaLinux 开发镜像 - 用于 HPC (已优化)
#
# 功能:
#   此 Dockerfile 继承自 alma-base 基础镜像，并安装了完整的
#   C++, Java 开发工具链以及增强的终端环境。
#

# --- 基础镜像 ---
# 通过构建参数指定基础镜像，默认为 'alma-base:latest'
ARG BASE_IMAGE=alma-base:latest
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="HPC 开发镜像，基于 AlmaLinux，预装了 C++/Java 工具链和 Oh My Zsh。"

# --- 构建参数 ---
# 接收开发用户名，用于后续的用户级配置
ARG DEV_USER=shijiashuai

# --- 安装核心开发工具链 ---
# 切换到 root 用户以安装系统级软件包
# 将所有安装和清理步骤合并到一个 RUN 指令中，以减少镜像层数
USER root
RUN dnf -y update && \
    # 安装开发工具 (按字母顺序排列)
    dnf -y install \
        clang \
        cmake \
        gdb \
        gcc-c++ \
        git \
        htop \
        java-11-openjdk-devel \
        maven \
        vim \
    # 清理 dnf 缓存以减小镜像体积
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- 用户级环境配置 (Oh My Zsh) ---
# 切换到开发用户来执行用户级别的安装，提升开发体验
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

# 将所有用户级配置合并到一个 RUN 指令中
RUN \
    # 1. 使用无人值守模式安装 Oh My Zsh (如果已存在则跳过)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
    # 2. 克隆 zsh 插件：命令自动建议和语法高亮
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    # 3. 自动在 .zshrc 中启用这些插件
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# --- 最终设置 ---
# 切换回 root 用户，并将默认工作目录设置为 /workspace
# 这样，当通过 `docker exec` 或 SSH 进入容器时，默认会在此目录
USER root
WORKDIR /workspace

# CMD 指令从基础镜像继承
