# FROM mcr.microsoft.com/devcontainers/base:ubuntu
FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04

# 设置维护者信息
LABEL maintainer="shijiashuai" description="cpp dev container for vscode"

# 设置非交互模式，避免在构建过程中出现提示
# ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y xz-utils \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    openssh-server

# 安装 samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 \
    && tar -xvf samtools-1.18.tar.bz2 \
    && cd samtools-1.18 \
    && ./configure \
    && make \
    && make install \
    && cd .. && rm -r samtools-1.18 samtools-1.18.tar.bz2

# 创建SSH配置目录
RUN mkdir /var/run/sshd

# 设置root用户的密码（如果需要）
RUN echo 'root:password' | chpasswd

# 允许root用户通过SSH登录
RUN sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 将SSH的登录提示关闭
RUN sed -i 's/.*UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# 暴露SSH的默认端口
EXPOSE 22

# 创建 lush-dev 用户组并指定 GID
RUN groupadd -g 2000 lush-dev

# 创建 shijiashuai 用户并指定 UID 以及其所属的组
RUN useradd -m -u 2034 -g lush-dev shijiashuai

# 将 shijiashuai 用户添加到 sudo 组
RUN usermod -aG sudo shijiashuai

# 允许 sudo 组的所有用户无需密码执行 sudo 命令
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 将工作目录的所有权赋予 shijiashuai 用户
RUN mkdir /workspace && chown -R shijiashuai:lush-dev /workspace

# 切换到 shijiashuai 用户
USER shijiashuai

# 设置工作目录
WORKDIR /workspace

# 安装 oh-my-zsh
# RUN sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# 克隆 oh-my-zsh 的仓库
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 安装 bwa
# RUN wget https://github.com/lh3/bwa/releases/download/v0.7.17/bwa-0.7.17.tar.bz2 \
#     && tar -xvf bwa-0.7.17.tar.bz2 \
#     && cd bwa-0.7.17 \
#     && make \
#     && mv bwa /usr/local/bin/ \
#     && cd .. && rm -r bwa-0.7.17

# 声明 VOLUME，为镜像创建挂载点
VOLUME ["/data", "/data1"]

# 设置启动SSH服务和zsh的命令
CMD ["/bin/sh", "-c", "/usr/sbin/sshd -D & exec zsh"]