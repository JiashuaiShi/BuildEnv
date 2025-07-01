#
# Web 开发镜像
#
# 功能:
#   此 Dockerfile 继承自 web-base 基础镜像，
#   并安装了通用的前端开发框架脚手架 (React, Vue)。
#

# --- 基础镜像 ---
ARG BASE_IMAGE=web-base:latest
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="Web 开发环境，预装了 Node.js, Python 和常见的前端开发工具。"

# --- 构建参数 ---
# 开发用户名已在基础镜像中创建，此处仅用于切换用户
ARG DEV_USER=shijiashuai

# --- 安装全局 Node.js 包和开发工具 ---
# 切换到 root 用户以安装软件包
USER root

RUN npm install -g \
    create-react-app \
    @vue/cli \
    # 在此处添加其他需要全局安装的 npm 包
    && apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    htop \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
# 将默认工作目录设置为 /workspace
USER root
WORKDIR /workspace

# CMD 指令从基础镜像继承
