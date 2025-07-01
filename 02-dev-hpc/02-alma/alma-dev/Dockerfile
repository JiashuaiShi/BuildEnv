#
# AlmaLinux 开发镜像 - 用于 HPC
#
# 功能:
#   此 Dockerfile 继承自 alma-base 基础镜像，
#   并安装了针对开发人员的额外工具，如 Oh My Zsh。
#

# --- 基础镜像 ---
# 通过构建参数指定基础镜像，默认为 'alma-base:latest'
ARG BASE_IMAGE=alma-base:latest
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="HPC 开发镜像，基于 AlmaLinux，预装了常用开发工具。"

# --- 安装开发工具 ---
# 切换到 root 用户以安装系统级软件包
USER root
RUN dnf -y update && dnf -y install \
    git \
    vim \
    htop \
    # 添加其他您需要的开发工具...
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# --- 安装 Oh My Zsh --- 
# 切换到开发用户来执行用户级别的安装
USER shijiashuai
# 设置工作目录为用户主目录
WORKDIR /home/shijiashuai

# 运行 Oh My Zsh 的无人值守安装脚本
# `if` 条件语句确保只有在 .oh-my-zsh 目录不存在时才执行安装，避免重复操作
RUN if [ ! -d ".oh-my-zsh" ]; then \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"; \
fi

# --- 最终设置 ---
# 切换回 root 用户，以便将容器的默认工作目录设置为 /workspace
# 这样，当通过 `docker exec` 进入容器时，默认会在此目录
USER root
WORKDIR /workspace
