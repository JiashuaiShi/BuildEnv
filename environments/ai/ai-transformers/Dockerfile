# 使用 huggingface/transformers-pytorch-gpu 作为基础镜像
FROM huggingface/transformers-pytorch-gpu:latest

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="huggingface/transformers test"

# 切换到 root 用户
USER root

# 更新与安装基础工具
RUN apt-get update && apt-get install -y \
    sudo \
    openssh-server \
    zsh python3 python3-pip jupyter \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install -no-cache-dir numpy pandas matplotlib scipy seaborn 

# 用户与SSH设置
RUN getent group lush-dev || groupadd -g 2000 lush-dev && \
    id -u shijiashuai &>/dev/null || useradd -m -u 2034 -g lush-dev shijiashuai && \
    echo 'root:0306' | chpasswd && \
    usermod -aG sudo shijiashuai && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir /workspace && chown -R shijiashuai:lush-dev /workspace && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Supervisor设置
RUN mkdir -p /etc/supervisor/conf.d && \
    echo '[supervisord]\nnodaemon=true\n' > /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:sshd]\ncommand=/usr/sbin/sshd -D\n' >> /etc/supervisor/conf.d/supervisord.conf

# 切换到新创建的用户
USER shijiashuai

# 安装oh-my-zsh
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 开放SSH端口
EXPOSE 22

# 设置VOLUME
VOLUME ["/data", "/data1"]

# 设置容器启动时运行的命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

