FROM ubuntu:24.04
# FROM shuai/ubuntu:24.04

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

# 替换apt源为国内镜像（阿里云）
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list

# 添加配置以忽略GPG签名验证和修复Post-Invoke脚本问题
RUN mkdir -p /etc/apt/apt.conf.d/ && \
    echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99allow-unauthenticated && \
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-unauthenticated && \
    echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-unauthenticated && \
    echo 'APT::Update::Post-Invoke-Success { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/99fixpostrm && \
    echo 'Dir::Etc::TrustedParts "/etc/apt/keyrings/";' > /etc/apt/apt.conf.d/99keyrings && \
    mkdir -p /etc/apt/keyrings

# 安装组件（使用更安全的参数组合跳过GPG验证）
# 拆分大型安装为多个小型安装，减少内存使用
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    ca-certificates \
    gnupg \
    wget \
    gpg \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装基础工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    build-essential \
    cmake \
    sudo \
    gdb \
    git \
    ninja-build \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装编译相关工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    autoconf \
    automake \
    libtool \
    locales-all \
    dos2unix \
    rsync \
    tar \
    xz-utils \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装开发库
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装编译器工具链
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    g++-13 \
    gcc-13 \
    cpp-13 \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装 clang 相关工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    clang \
    clang-tools \
    clangd \
    llvm \
    lldb \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装 Python 相关
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装其他工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    valgrind \
    vim \
    curl \
    wget \
    zsh \
    htop \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 安装和配置SSH
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    openssh-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true && \
    mkdir -p /var/run/sshd

# 尝试安装额外库（如果内存允许）
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    libboost-all-dev \
    libhts-dev \
    || true && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

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
    chown -R shijiashuai:lush-dev /data-lush && \
    chsh -s /usr/bin/zsh shijiashuai && \
    chmod 755 /home/shijiashuai

# SSH配置 - 条件检查确保文件存在
RUN if [ -f /etc/ssh/sshd_config ]; then \
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config; \
    else \
        echo "PermitRootLogin yes" > /etc/ssh/sshd_config && \
        echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config; \
    fi && \
    if [ -f /etc/pam.d/sshd ]; then \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
    fi && \
    mkdir -p /var/run/sshd

# 创建目录并设置权限
RUN mkdir -p /home/shijiashuai && \
    chown -R shijiashuai:lush-dev /data-lush && \
    chsh -s /usr/bin/zsh shijiashuai && \
    chmod 755 /home/shijiashuai

# 切换用户并设置工作目录
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装Miniconda - 使用更可靠的下载方式和超时设置
RUN curl -s -L --connect-timeout 30 --max-time 300 -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh || \
    wget -q --timeout=300 -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh || \
    echo "Failed to download Miniconda"

# 安装并配置Miniconda - 简化安装过程
RUN if [ -f /tmp/miniconda.sh ]; then \
        bash /tmp/miniconda.sh -b -p $HOME/miniconda && \
        rm -f /tmp/miniconda.sh && \
        export PATH="$HOME/miniconda/bin:$PATH" && \
        echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc && \
        echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.zshrc && \
        $HOME/miniconda/bin/conda config --set auto_activate_base false && \
        $HOME/miniconda/bin/conda config --set ssl_verify false && \
        $HOME/miniconda/bin/conda config --set remote_read_timeout_secs 600 && \
        $HOME/miniconda/bin/conda config --set remote_connect_timeout_secs 60 && \
        $HOME/miniconda/bin/conda config --set remote_max_retries 10; \
    fi

# 安装oh-my-zsh - 添加超时设置和简化安装
RUN curl -fsSL --connect-timeout 30 --max-time 120 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/install-zsh.sh && \
    (sh /tmp/install-zsh.sh --unattended || echo "Failed to install oh-my-zsh") && \
    rm -f /tmp/install-zsh.sh && \
    mkdir -p ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins && \
    (git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true) && \
    (git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true) && \
    if [ -f $HOME/.zshrc ]; then \
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true; \
    fi

# 添加自定义工具到PATH
RUN echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> $HOME/.zshrc && \
    echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> $HOME/.bashrc

# 切回root用户完成剩余配置
USER root

# Supervisor配置
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 开放SSH端口
EXPOSE 22

# 设置VOLUME
# VOLUME ["/data", "/data1", "/data2", "/data-lush", "/data_test", "/mnt/nas1", "/data_melody", "/data-melody"]

# 设置容器启动命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 