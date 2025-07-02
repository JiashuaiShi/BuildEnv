#
# Dockerfile for Web Development Environment
#

# 使用官方 Node.js 18 作为基础镜像
FROM node:18-bullseye

# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装常用工具
RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    zsh \
    openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建 SSH 服务所需目录
RUN mkdir /var/run/sshd

# 配置 SSH
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 暴露 SSH 端口
EXPOSE 22

# 创建非 root 用户并设置工作目录
RUN useradd -m -s /bin/zsh node && \
    echo "node:password" | chpasswd

# 设置工作目录
WORKDIR /workspace

# 切换到非 root 用户
USER node

# 启动容器时运行的命令
CMD ["/usr/sbin/sshd", "-D"]