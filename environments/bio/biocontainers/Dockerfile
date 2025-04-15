# 使用 biocontainers 作为基础镜像
FROM biocontainers/biocontainers:latest

# 设置全局环境变量，包括代理和非交互模式
# ENV DEBIAN_FRONTEND=noninteractive \
#     http_proxy=http://172.19.11.241:443 \
#     https_proxy=http://172.19.11.241:443 \
#     no_proxy=localhost,127.*,10.*,172.16.*,172.17.*,172.18.*,172.19.*,172.20.*,172.21.*,172.22.*,172.23.*,172.24.*,172.25.*,172.26.*,172.27.*,172.28.*,172.29.*,172.30.*,172.31.*,192.168.* \
#     CONDA_SSL_VERIFY=false
# Use ARG for build-time proxy and ENV noninteractive
ARG http_proxy
ARG https_proxy
ENV DEBIAN_FRONTEND=noninteractive
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
# ENV CONDA_SSL_VERIFY=false

# 切换到 root 用户执行安装软件包等操作
USER root

# --- Run Common User Setup Script ---
# Installs: sudo, openssh-server, zsh, supervisor, user/group, basic ssh/supervisor conf
COPY ../../scripts/common-user-setup.sh /tmp/
RUN chmod +x /tmp/common-user-setup.sh && \
    bash /tmp/common-user-setup.sh && \
    rm /tmp/common-user-setup.sh

# 安装特定工具 (如果基础镜像没有)
# RUN apt-get update && apt-get install -y --no-install-recommends vim && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Configure Supervisor (Specific Program) ---
# Base directory and log files created by common script
RUN echo '[supervisord]\nnodaemon=true\nuser=root\n' > /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\nuser=root\n' >> /etc/supervisor/conf.d/supervisord.conf && \
    chmod 644 /etc/supervisor/conf.d/supervisord.conf

# 切换到普通用户
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装 oh-my-zsh
RUN rm -rf /home/shijiashuai/.oh-my-zsh && \
    (git clone https://gitee.com/mirrors/oh-my-zsh.git /home/shijiashuai/.oh-my-zsh || \
     git clone https://github.com/ohmyzsh/ohmyzsh.git /home/shijiashuai/.oh-my-zsh) && \
    cp /home/shijiashuai/.oh-my-zsh/templates/zshrc.zsh-template /home/shijiashuai/.zshrc && \
    chown -R shijiashuai:lush-dev /home/shijiashuai/.oh-my-zsh /home/shijiashuai/.zshrc

# 清理代理环境变量
USER root
ENV http_proxy=""
ENV https_proxy=""

# 开放SSH端口
EXPOSE 22

# 设置VOLUME
VOLUME ["/data", "/data1", "/workspace"]

# 设置容器启动时运行的命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]