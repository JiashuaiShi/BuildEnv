#
# Ubuntu 开发镜像 - 用于 HPC (已优化)
#
# 功能:
#   此 Dockerfile 继承自 ubuntu-base 基础镜像，并安装了与 AlmaLinux 环境
#   功能对等的 C++, Java 开发工具链以及增强的终端环境。
#

# --- 基础镜像 ---
# 通过构建参数指定基础镜像和开发用户名
ARG BASE_IMAGE=ubuntu-base:latest
ARG DEV_USER=shijiashuai
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="用于HPC开发的Ubuntu镜像，预装了C++/Java工具链和Oh My Zsh。"

# --- 安装核心开发工具链 ---
# 切换到 root 用户以安装系统级软件包
# 将所有安装和清理步骤合并到一个 RUN 指令中，以减少镜像层数
USER root
RUN apt-get update && \
    # 安装开发工具 (按字母顺序排列)
    apt-get install -y --no-install-recommends \
        clang \
        cmake \
        g++ \
        gdb \
        git \
        htop \
        maven \
        openjdk-11-jdk \
        vim \
    # 清理 apt 缓存以减小镜像体积
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
