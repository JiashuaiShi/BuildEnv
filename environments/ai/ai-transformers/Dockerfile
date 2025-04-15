# 使用 huggingface/transformers-pytorch-gpu 作为基础镜像
FROM huggingface/transformers-pytorch-gpu:latest

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="huggingface/transformers test"

# 切换到 root 用户
USER root

# --- Run Common User Setup Script ---
# Installs: sudo, openssh-server, zsh, supervisor, user/group, basic ssh/supervisor conf
COPY ../../scripts/common-user-setup.sh /tmp/
RUN chmod +x /tmp/common-user-setup.sh && \
    bash /tmp/common-user-setup.sh && \
    rm /tmp/common-user-setup.sh

# --- Install Environment Specific Tools ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip jupyter \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir numpy pandas matplotlib scipy seaborn
    # Note: python3 should already be present in the base image

# --- Configure Supervisor (Specific Program) ---
# Base directory and log files created by common script
RUN echo '[supervisord]\nnodaemon=true\nuser=root\n' > /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\nuser=root\n' >> /etc/supervisor/conf.d/supervisord.conf && \
    chmod 644 /etc/supervisor/conf.d/supervisord.conf

# 切换到普通用户
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装oh-my-zsh
RUN rm -rf /home/shijiashuai/.oh-my-zsh && \
    (git clone https://gitee.com/mirrors/oh-my-zsh.git /home/shijiashuai/.oh-my-zsh || \
     git clone https://github.com/ohmyzsh/ohmyzsh.git /home/shijiashuai/.oh-my-zsh) && \
    cp /home/shijiashuai/.oh-my-zsh/templates/zshrc.zsh-template /home/shijiashuai/.zshrc && \
    chown -R shijiashuai:lush-dev /home/shijiashuai/.oh-my-zsh /home/shijiashuai/.zshrc

# 开放SSH端口
EXPOSE 22

# 设置VOLUME
VOLUME ["/data", "/data1", "/workspace"]

# 设置容器启动时运行的命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

