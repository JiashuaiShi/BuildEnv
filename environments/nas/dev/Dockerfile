#
# NAS 管理开发镜像 (已优化)
#
# 功能:
#   此 Dockerfile 继承自 nas-base 基础镜像，并为管理员安装了
#   额外的便利工具和增强的终端环境。
#

# --- 基础镜像 ---
ARG BASE_IMAGE=nas-base:latest
ARG DEV_USER=shijiashuai
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="NAS 管理环境，预装了 Samba, NFS, 和 Oh My Zsh。"

# --- 安装额外工具 ---
# 切换到 root 用户以安装软件包
# 将所有安装和清理步骤合并到一个 RUN 指令中，以减少镜像层数
USER root
RUN dnf -y update && \
    # 安装管理工具 (按字母顺序排列)
    dnf -y install \
        git \
        htop \
        vim \
    # 清理 dnf 缓存以减小镜像体积
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- 用户级环境配置 (Oh My Zsh) ---
# 切换到开发用户以执行用户级别的安装
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
# 切换回 root 用户。
# 将默认工作目录设置为 /export，以方便管理 NAS 共享目录。
USER root
WORKDIR /export

# CMD 指令从基础镜像继承
