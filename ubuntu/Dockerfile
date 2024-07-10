# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="ubuntu for cpp dev"

# 更新与安装基础工具
RUN apt-get update && apt-get install -y \
    build-essential cmake sudo gdb git ninja-build autoconf automake libtool locales-all dos2unix rsync tar python3 python3-dev clang valgrind vim xz-utils zlib1g-dev libncurses5-dev libbz2-dev liblzma-dev zsh openssh-server supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# 用户与SSH设置
RUN groupadd -g 2000 lush-dev && \
    useradd -m -u 2034 -g lush-dev shijiashuai && \
    echo 'root:0306' | chpasswd && \
    usermod -aG sudo shijiashuai && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir /workspace && chown -R shijiashuai:lush-dev /workspace && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# 切换到新创建的用户
USER shijiashuai

# 更多设置（作为新用户）
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 切换回root用户，以便进行更多设置
USER root

# Supervisor设置
RUN mkdir -p /etc/supervisor/conf.d && \
    echo '[supervisord]\nnodaemon=true\n' > /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\n' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:zsh]\ncommand=/usr/bin/zsh\nautorestart=false\n' >> /etc/supervisor/conf.d/supervisord.conf

# 开放SSH端口
EXPOSE 22

# 设置VOLUME
VOLUME ["/data", "/data1"]

# 设置容器启动时运行的命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
