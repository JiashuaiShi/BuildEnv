FROM ubuntu-base-systemd:latest

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="dev environment systemd"

# 避免交互式提示 (已经在 base 设置，保留以防万一)
ENV DEBIAN_FRONTEND=noninteractive
# 时区 (已经在 base 设置)
# ENV TZ=Asia/Shanghai

# 基础镜像已更新apt源和处理GPG

# --- 安装开发环境所需的基础组件 ---
# (systemd, dbus, locales, tzdata 已经在 base 安装)
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    gnupg \
    wget \
    gpg \
    curl \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# --- 创建用户和组，并配置 sudo ---
RUN groupadd --gid 1000 lush-dev || true && \
    useradd --uid 1000 --gid 1000 --groups sudo --create-home --shell /bin/bash shijiashuai && \
    # 设置一个默认密码（建议在首次登录时更改）
    echo "shijiashuai:password" | chpasswd && \
    # 配置无密码 sudo
    echo "shijiashuai ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/shijiashuai-nopasswd && \
    chmod 0440 /etc/sudoers.d/shijiashuai-nopasswd

#################################################
# C++开发环境安装部分
#################################################
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    gdb \
    git \
    ninja-build \
    autoconf \
    automake \
    libtool \
    dos2unix \
    rsync \
    tar \
    xz-utils \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    # Atomic operations library
    libatomic1 \
    # Sanitizer development libraries
    libasan-dev \
    libtsan-dev \
    # 编译器
    g++-13 \
    gcc-13 \
    cpp-13 \
    # Clang
    clang \
    clang-tools \
    clangd \
    llvm \
    lldb \
    libubsan-dev \
    # 其他工具
    valgrind \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 设置默认 GCC/G++
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100

#################################################
# Java开发环境安装部分
#################################################
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    maven \
    gradle \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 配置Java alternatives
RUN for version in 8 11 17; do \
        if [ -d "/usr/lib/jvm/java-${version}-openjdk-amd64" ]; then \
            update-alternatives --install /usr/bin/java java "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/java" ${version}0 || true && \
            update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/javac" ${version}0 || true && \
            update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/jar" ${version}0 || true && \
            update-alternatives --install /usr/bin/javadoc javadoc "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/javadoc" ${version}0 || true; \
        fi \
    done

# 设置默认JDK版本为JDK 11
RUN if [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then \
        update-alternatives --set java "/usr/lib/jvm/java-11-openjdk-amd64/bin/java" || true && \
        update-alternatives --set javac "/usr/lib/jvm/java-11-openjdk-amd64/bin/javac" || true && \
        update-alternatives --set jar "/usr/lib/jvm/java-11-openjdk-amd64/bin/jar" || true && \
        update-alternatives --set javadoc "/usr/lib/jvm/java-11-openjdk-amd64/bin/javadoc" || true; \
    fi

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

#################################################
# Python开发环境安装部分
#################################################
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# 通用开发工具安装
#################################################
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends \
    vim \
    neovim \
    htop \
    less \
    tmux \
    perl \
    zsh \
    openssh-server \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 配置 SSH
RUN mkdir -p /var/run/sshd && \
    # 允许 root 登录（如果需要，通常不推荐，但有时开发环境需要）
    # sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # 允许密码认证（如果需要）
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    # 禁用 UsePAM
    sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
    # 启用 SSH 服务
    systemctl enable ssh

# --- 安装 Netdata ---
# (如果基础镜像网络受限，下载可能失败)
RUN bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait --non-interactive || echo "Netdata installation skipped or failed"
# 启用 Netdata 服务 (如果安装成功)
RUN if [ -f /etc/systemd/system/netdata.service ]; then systemctl enable netdata; fi

#################################################
# 工具配置部分
#################################################

# 创建JDK版本切换脚本
COPY --chown=root:root jdk_switcher.sh /usr/local/bin/jdk
RUN chmod +x /usr/local/bin/jdk

# 创建 JDK 别名（将在用户配置中添加到 .bashrc/.zshrc）
# 注意：直接修改 /etc/bash.bashrc 在 systemd 容器中可能不总是生效，最好在用户配置中添加

#################################################
# 用户环境配置 (切换到用户)
#################################################
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装 Miniconda
RUN wget -q -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $HOME/miniconda && \
    rm -f /tmp/miniconda.sh && \
    $HOME/miniconda/bin/conda init bash && \
    $HOME/miniconda/bin/conda init zsh && \
    $HOME/miniconda/bin/conda config --set always_yes yes && \
    $HOME/miniconda/bin/conda config --set auto_activate_base false && \
    $HOME/miniconda/bin/conda config --set ssl_verify false && \
    $HOME/miniconda/bin/conda config --set remote_read_timeout_secs 600 && \
    $HOME/miniconda/bin/conda config --set remote_connect_timeout_secs 60 && \
    $HOME/miniconda/bin/conda config --set concurrent_download_threads 1 && \
    $HOME/miniconda/bin/conda config --set remote_max_retries 10

# 安装oh-my-zsh和插件
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
RUN git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
RUN sed -i 's/^plugins=(git)/plugins=(git sudo maven gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true

# 添加 JDK 切换别名到 .bashrc 和 .zshrc
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.bashrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.bashrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.bashrc
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc

# 添加自定义工具到 PATH
RUN echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> $HOME/.bashrc && \
    echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> $HOME/.zshrc

# --- Install Python Packages using Conda's pip ---
RUN $HOME/miniconda/bin/pip install --no-cache-dir matplotlib psrecord || echo "Miniconda pip install failed"

#################################################
# 最终配置
#################################################
# 切换回 root 以完成可能需要的系统级操作（如果需要）
# USER root

# 暴露端口
EXPOSE 22
EXPOSE 28970

# 设置默认用户和工作目录 (容器启动后生效)
USER shijiashuai
WORKDIR /home/shijiashuai

# systemd 将由基础镜像的 ENTRYPOINT/CMD 启动

# 安装 sbt (Scala Build Tool)
# 需要 gnupg (已安装) 和 curl (已安装)
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import && \
    chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends sbt && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# Go 开发环境安装部分
#################################################
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends golang-go && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# Rust 开发环境安装部分
#################################################
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends rustc cargo && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true