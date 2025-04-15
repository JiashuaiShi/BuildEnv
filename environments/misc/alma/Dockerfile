# 使用 AlmaLinux 9 作为基础镜像
FROM almalinux/9-init:latest

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="CentOS for cpp dev"

# 安装必要的程序
RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install python3-pip && \
    pip3 install supervisor && \
    dnf -y install epel-release cmake sudo gdb git python3 python3-devel clang valgrind vim xz zlib-devel ncurses-devel bzip2-devel xz-devel zsh openssh-server && \
    dnf clean all

# 设置 SSH 和用户信息
RUN ssh-keygen -A && \
    echo 'root:0306' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    groupadd -g 2000 lush-dev && \
    useradd -m -u 2034 -g lush-dev shijiashuai && \
    echo '%lush-dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /workspace && chown -R shijiashuai:lush-dev /workspace

# 设置 Supervisor
RUN echo '[supervisord]\nnodaemon=true\n' > /etc/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\n' >> /etc/supervisord.conf && \
    echo '[program:zsh]\ncommand=/usr/bin/zsh\nautorestart=false\n' >> /etc/supervisord.conf

# 安装 oh-my-zsh
USER shijiashuai
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 切换回 root 用户
USER root

# 开放 SSH 端口
EXPOSE 22

# 设置 VOLUME
VOLUME ["/data", "/data1"]

# 设置容器启动时运行的命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
