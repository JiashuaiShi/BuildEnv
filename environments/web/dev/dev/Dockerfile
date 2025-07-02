#
# Web 开发镜像 (已优化)
#
# 功能:
#   此 Dockerfile 继承自 web-base 基础镜像，并安装了现代 Web 开发
#   所需的通用工具链和增强的终端环境。
#

# --- 基础镜像 ---
ARG BASE_IMAGE=web-base:latest
ARG DEV_USER=shijiashuai
FROM ${BASE_IMAGE}

# --- 镜像元数据 ---
LABEL maintainer="Cascade AI Assistant"
LABEL description="Web 开发环境，预装了现代前端开发工具链和 Oh My Zsh。"

# --- 安装系统级开发工具 ---
# 切换到 root 用户以安装软件包
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        htop \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- 安装全局 Node.js 包 ---
# 安装通用的全局工具。注意：现代前端开发已不推荐全局安装 create-react-app 或 @vue/cli，
# 而是推荐使用 `npx create-react-app` 或 `pnpm create vue` 等命令来初始化项目。
RUN npm install -g \
    nodemon \
    pnpm \
    typescript \
    yarn

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
# 切换回 root 用户，并将默认工作目录设置为 /workspace
USER root
WORKDIR /workspace

# CMD 指令从基础镜像继承
