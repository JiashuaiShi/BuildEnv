#
# NAS 管理开发镜像
#
# 功能:
#   此 Dockerfile 继承自 nas-base 基础镜像，
#   并为管理员安装了额外的便利工具，如 Oh My Zsh。
#

# --- 基础镜像 ---
ARG BASE_IMAGE=nas-base:latest
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="NAS 管理环境，预装了 Samba, NFS, 和 Oh My Zsh。"

# --- 构建参数 ---
# 开发用户名已在基础镜像中创建，此处仅用于切换用户
ARG DEV_USER=shijiashuai

# --- 安装额外工具 ---
# 切换到 root 用户以安装软件包
USER root

RUN dnf -y install git vim htop && dnf clean all

# --- 用户级配置 (Oh My Zsh) ---
# 切换到开发用户以执行用户级别的安装
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

# 安装 Oh My Zsh 及其常用插件
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# --- 最终设置 ---
# 切换回 root 用户。容器将由 Docker 以 root 身份启动。
# 将默认工作目录设置为 /export，方便管理共享目录
USER root
WORKDIR /export

# CMD 指令从基础镜像继承
