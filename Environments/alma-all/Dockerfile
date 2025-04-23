# 使用 AlmaLinux 9 作为基础镜像
FROM almalinux/9-init:latest

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="AlmaLinux 9 for C++/Java/Python dev"

# 安装必要的程序
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install epel-release cmake sudo gdb git python3 python3-pip python3-devel clang valgrind vim xz zlib-devel ncurses-devel bzip2-devel xz-devel zsh openssh-server supervisor && \
    dnf clean all

# 设置 SSH 和用户信息
RUN ssh-keygen -A && \
    echo 'root:0306' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    groupadd -g 2000 lush-dev && \
    useradd -m -d /home/shijiashuai -s /bin/zsh -u 2034 -g lush-dev shijiashuai && \
    echo 'shijiashuai:phoenix2024' | chpasswd && \
    echo '%lush-dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /workspace && chown -R shijiashuai:lush-dev /workspace

# 创建 Supervisor 日志目录
RUN mkdir -p /var/log/supervisor

# 复制 Supervisor 配置文件
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 安装 oh-my-zsh for the user shijiashuai
USER shijiashuai
WORKDIR /home/shijiashuai
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git .oh-my-zsh && \
    cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc && \
    echo "ZSH_DISABLE_COMPFIX=true" >> .zshrc

# 切换回 root 用户进行后续操作
USER root
WORKDIR /

# 开放 SSH 端口
EXPOSE 22

# 设置 VOLUME
VOLUME ["/workspace", "/data", "/data1"]

# 设置容器启动时运行的命令为 supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
