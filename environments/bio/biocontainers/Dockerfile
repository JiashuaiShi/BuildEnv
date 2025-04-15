# 使用 biocontainers 作为基础镜像
FROM biocontainers/biocontainers:latest

# 设置全局环境变量，包括代理和非交互模式
ENV DEBIAN_FRONTEND=noninteractive \
    http_proxy=http://172.19.11.241:443 \
    https_proxy=http://172.19.11.241:443 \
    no_proxy=localhost,127.*,10.*,172.16.*,172.17.*,172.18.*,172.19.*,172.20.*,172.21.*,172.22.*,172.23.*,172.24.*,172.25.*,172.26.*,172.27.*,172.28.*,172.29.*,172.30.*,172.31.*,192.168.* \
    CONDA_SSL_VERIFY=false

# 切换到 root 用户执行安装软件包等操作
USER root

# 安装必要的工具和依赖项，包括 C++ 编程依赖
RUN apt-get update && apt-get install -y \
    sudo vim zsh openssh-server supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置SSH和用户信息
RUN mkdir -p /var/run/sshd \
    && echo 'root:0306' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && groupadd -g 2000 lush-dev \
    && usermod -l shijiashuai -u 2034 -g lush-dev biodocker \
    && echo 'shijiashuai:0306' | chpasswd \
    && usermod -aG sudo shijiashuai \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir /workspace \
    && chown -R shijiashuai:lush-dev /workspace \
    && mkdir -p /etc/supervisor/conf.d \
    && echo '[supervisord]\nnodaemon=true\n' > /etc/supervisor/conf.d/supervisord.conf \
    && echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\n' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '[program:zsh]\ncommand=/usr/bin/zsh\nautorestart=false\n' >> /etc/supervisor/conf.d/supervisord.conf

# 切换到新创建的用户
USER shijiashuai

# 安装 oh-my-zsh
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 开放SSH端口
EXPOSE 22

# 设置VOLUME
VOLUME ["/data", "/data1"]

# 设置容器启动时运行的命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]