# FROM ubuntu:24.04
FROM shuai/ubuntu:24.04

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Ubuntu dev Container - C++17+/Python/Conda"

# 接收构建参数
ARG http_proxy
ARG https_proxy

# 在构建时设置代理环境变量
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 添加Ubuntu仓库密钥
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates gnupg wget gpg && \
    wget --no-background -O key.asc "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C" && \
    gpg --dearmor < key.asc > /etc/apt/trusted.gpg.d/ubuntu-keyring.gpg && \
    rm -f key.asc && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# 安装组件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    wget \
    gpg \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# 继续安装其他组件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential cmake sudo gdb git ninja-build \
    autoconf automake libtool locales-all dos2unix \
    rsync tar xz-utils zlib1g-dev libncurses5-dev \
    libbz2-dev liblzma-dev \
    g++-13 gcc-13 cpp-13 clang clang-tools clangd llvm lldb \
    python3 python3-dev python3-pip python3-venv \
    valgrind vim curl wget \
    openssh-server supervisor \
    libboost-all-dev \
    libhts-dev \
    zsh htop \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# 清理代理设置，确保最终镜像不包含代理
ENV http_proxy=""
ENV https_proxy=""

# 确保C++17支持
RUN if [ -f /usr/bin/g++-13 ]; then \
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
        g++ --version; \
    fi

# 用户与SSH设置
RUN groupadd -g 2000 lush-dev && \
    useradd -m -u 2034 -g lush-dev shijiashuai && \
    echo 'shijiashuai:phoenix2024' | chpasswd && \
    usermod -aG sudo shijiashuai && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /workspace && chown -R shijiashuai:lush-dev /workspace && \
    mkdir -p /data-lush/lush-dev/shijiashuai/build-tools/apps && \
    chown -R shijiashuai:lush-dev /data-lush

# SSH配置
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# 安装Miniconda - 为shijiashuai用户安装
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装Miniconda
RUN curl -s -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash miniconda.sh -b -p $HOME/miniconda && \
    rm miniconda.sh && \
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.zshrc && \
    $HOME/miniconda/bin/conda init bash && \
    $HOME/miniconda/bin/conda init zsh

# 安装oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# 添加自定义工具到PATH
RUN echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> ~/.zshrc && \
    echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> ~/.bashrc

USER root

# Supervisor配置
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 开放SSH端口
EXPOSE 22

# 设置容器启动命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]