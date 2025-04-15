# 使用 huggingface/transformers-pytorch-gpu 作为基础镜像
FROM docker.io/jupyter/tensorflow-notebook:latest

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="jupyter/tensorflow-notebook test"

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
    && rm -rf /var/lib/apt/lists/*
    # Note: python3 should already be present in the base image or installed by common script if needed

# --- Configure Supervisor (Specific Program) ---
# Base directory and log files created by common script
# Overwrite base supervisord.conf if needed, or add specific program conf
RUN echo '[supervisord]\nnodaemon=true\nuser=root\n' > /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\nuser=root\n' >> /etc/supervisor/conf.d/supervisord.conf && \
    # Optional: Add jupyter notebook startup here if needed via supervisor
    chmod 644 /etc/supervisor/conf.d/supervisord.conf

# 切换到普通用户
USER shijiashuai
WORKDIR /home/shijiashuai # Ensure WORKDIR is set after USER switch

# 安装oh-my-zsh
RUN rm -rf /home/shijiashuai/.oh-my-zsh && \
    (git clone https://gitee.com/mirrors/oh-my-zsh.git /home/shijiashuai/.oh-my-zsh || \
     git clone https://github.com/ohmyzsh/ohmyzsh.git /home/shijiashuai/.oh-my-zsh) && \
    cp /home/shijiashuai/.oh-my-zsh/templates/zshrc.zsh-template /home/shijiashuai/.zshrc && \
    # Add plugins if needed, e.g., conda if installed
    # sed -i 's/plugins=(git)/plugins=(git conda)/' /home/shijiashuai/.zshrc && \
    chown -R shijiashuai:lush-dev /home/shijiashuai/.oh-my-zsh /home/shijiashuai/.zshrc

# 开放SSH端口
EXPOSE 22
# Expose Jupyter port if not done by base image or started differently
# EXPOSE 8888

# 设置VOLUME
VOLUME ["/data", "/data1", "/workspace"] # Adjusted volumes

# 设置容器启动时运行的命令 (Supervisord starts sshd)
# CMD instruction from base image might handle Jupyter startup. If not, add to supervisor or modify CMD.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

