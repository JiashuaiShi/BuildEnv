# 使用 AlmaLinux 9 作为基础镜像
FROM almalinux/9-init:latest

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="AlmaLinux C++/Python Dev Environment"

# --- Run Common AlmaLinux Setup Script ---
# Installs: sudo, zsh, openssh-server, supervisor, user/group, basic conf
COPY ../../scripts/common-user-setup-alma.sh /tmp/
RUN chmod +x /tmp/common-user-setup-alma.sh && \
    bash /tmp/common-user-setup-alma.sh && \
    rm /tmp/common-user-setup-alma.sh

# --- Install Environment Specific Tools ---
# Install Development Tools group and other C++/Python essentials
RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install \
    epel-release \
    cmake \
    gdb \
    git \
    python3-devel \
    clang \
    valgrind \
    vim \
    xz \
    zlib-devel \
    ncurses-devel \
    bzip2-devel \
    xz-devel \
    && dnf -y clean all \
    && rm -rf /var/cache/dnf/*

# --- Configure Supervisor ---
# Base dirs created by script. Define specific programs.
# Assuming supervisor installed via pip puts config in /etc/supervisor/
RUN echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\nautostart=true\nautorestart=true\nuser=root\n' >> /etc/supervisor/conf.d/sshd.conf
# Need a main supervisord.conf file if not created by pip install
RUN echo '[supervisord]\nnodaemon=true\nuser=root\nlogfile=/var/log/supervisor/supervisord.log\npidfile=/var/run/supervisord.pid\n\n[include]\nfiles = /etc/supervisor/conf.d/*.conf\n' > /etc/supervisord.conf
# Adjust paths if pip installs config elsewhere (e.g., /usr/local/etc/)

# 切换到普通用户
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装 oh-my-zsh
RUN rm -rf /home/shijiashuai/.oh-my-zsh && \
    (git clone https://gitee.com/mirrors/oh-my-zsh.git /home/shijiashuai/.oh-my-zsh || \
     git clone https://github.com/ohmyzsh/ohmyzsh.git /home/shijiashuai/.oh-my-zsh) && \
    cp /home/shijiashuai/.oh-my-zsh/templates/zshrc.zsh-template /home/shijiashuai/.zshrc && \
    chown -R shijiashuai:lush-dev /home/shijiashuai/.oh-my-zsh /home/shijiashuai/.zshrc

# 切换回 root 用户
USER root

# 开放 SSH 端口
EXPOSE 22

# 设置 VOLUME
VOLUME ["/data", "/data1", "/workspace"]

# 设置容器启动命令 - Use Supervisor
# Ensure the path to supervisord executable and config file are correct
# Default pip install might put it in /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
