FROM shuai/ubuntu-base-systemd:latest

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Ubuntu dev environment with systemd"

# ARG for setup mode
ARG SETUP_MODE=systemd

# --- Build Arguments for User/Group (These are now handled by the script if hardcoded there, or should be passed to script if script uses ARGs) --- #
# ARG USER_NAME=shijiashuai
# ARG USER_ID=2034
# ARG GROUP_NAME=lush-dev
# ARG GROUP_ID=2000
# ARG USER_PASSWORD=password
# ARG ROOT_PASSWORD=password

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# --- Configure APT sources for Aliyun mirror using the required Ubuntu Key ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg wget \
    && rm -rf /var/lib/apt/lists/* \
    # Define variables within the RUN command's shell environment
    && ALIYUN_MIRROR_URL="http://mirrors.aliyun.com/ubuntu/" \
    && MISSING_KEY_ID="871920D1991BC93C" \
    && KEY_FILE_PATH="/usr/share/keyrings/ubuntu-archive-${MISSING_KEY_ID}.gpg" \
    \
    # 1. (可选) 禁用官方源配置文件，避免冲突
    && if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
           mv /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.disabled; \
           echo "Disabled /etc/apt/sources.list.d/ubuntu.sources"; \
       else \
           echo "/etc/apt/sources.list.d/ubuntu.sources not found, skipping disable."; \
       fi \
    \
    # 2. 创建 /etc/apt/sources.list 指向阿里云, 并指定用下载的 Ubuntu 密钥验证
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble main restricted universe multiverse" > /etc/apt/sources.list \
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    \
    # 3. 下载缺失的 Ubuntu GPG 密钥并保存到指定路径
    && echo "Downloading GPG key ${MISSING_KEY_ID} to ${KEY_FILE_PATH}..." \
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${MISSING_KEY_ID}" | gpg --dearmor -o "${KEY_FILE_PATH}" \
    && chmod 644 "${KEY_FILE_PATH}" \
    # Verify key download
    && if [ ! -s "${KEY_FILE_PATH}" ]; then echo "Error: Failed to download GPG key ${MISSING_KEY_ID}."; exit 1; fi \
    && echo "GPG key downloaded and permissions set." \
    \
    # 4. Clean up before the next step's update
    && apt-get clean

# --- Update APT cache using the new sources and key ---
# Fail build if update fails due to key/source issues
RUN apt-get update

# --- Unified Setup Script Handles Base Packages, User/Group, Sudo --- #
# REMOVED redundant package installs and user setup here

# --- Run Unified Common User Setup Script ---
# This script handles: installing base tools (sudo, zsh, sshd, etc.),
# creating user/group, configuring SSH & sudo, creating base directories
COPY common/docker-setup-scripts/unified-common-setup.sh /tmp/
RUN chmod +x /tmp/unified-common-setup.sh && \
    export SETUP_MODE=${SETUP_MODE} && \
    /tmp/unified-common-setup.sh && \
    rm /tmp/unified-common-setup.sh

# --- SSH Configuration (Systemd Specific) --- #
# unified-common-setup.sh skips config for systemd mode
# Apply necessary SSH config for systemd environment
RUN sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    # 确保 ssh 服务已启用 (基础镜像可能已做)
    systemctl enable ssh

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
    libatomic1 \
    libasan-dev \
    libtsan-dev \
    libubsan-dev \
    g++-13 \
    gcc-13 \
    cpp-13 \
    clang \
    clang-tools \
    clangd \
    llvm \
    lldb \
    valgrind \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true && \
    if [ -f /usr/bin/gcc-13 ]; then \
        echo "Setting alternatives for gcc-13/g++-13..." && \
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100; \
    else \
        echo "WARNING: /usr/bin/gcc-13 not found after install. Skipping update-alternatives for gcc-13."; \
    fi

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
    # 添加 Go 和 Rust
    golang-go \
    rustc cargo \
    # 添加 netdata 包
    netdata \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# --- 安装 sbt (Scala Build Tool) ---
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import && \
    chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends sbt && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# 工具配置部分
#################################################
COPY --chown=root:root Environments/ubuntu-systemd/jdk_switcher.sh /usr/local/bin/jdk
RUN chmod +x /usr/local/bin/jdk

#################################################
# 用户环境配置 (切换到用户)
#################################################
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 安装 Miniconda (统一逻辑)
RUN wget -q -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p $HOME/miniconda && \
    rm -f /tmp/miniconda.sh && \
    $HOME/miniconda/bin/conda init bash && \
    $HOME/miniconda/bin/conda init zsh && \
    $HOME/miniconda/bin/conda config --set always_yes yes && \
    $HOME/miniconda/bin/conda config --set auto_activate_base false && \
    $HOME/miniconda/bin/conda config --set ssl_verify false && \
    $HOME/miniconda/bin/conda config --set remote_read_timeout_secs 600 && \
    $HOME/miniconda/bin/conda config --set remote_connect_timeout_secs 60 && \
    $HOME/miniconda/bin/conda config --set remote_max_retries 10

# 安装oh-my-zsh和插件 (统一插件列表)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
RUN git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
RUN sed -i 's/^plugins=(.*)/plugins=(git sudo gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true

# 添加 JDK 切换别名到 .bashrc 和 .zshrc
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.bashrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.bashrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.bashrc
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc

# 添加自定义工具到 PATH
RUN echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:$PATH\"" >> $HOME/.bashrc && \
    echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:$PATH\"" >> $HOME/.zshrc

# --- Install Python Packages using Conda's pip ---
RUN $HOME/miniconda/bin/pip install --no-cache-dir matplotlib psrecord || echo "Miniconda pip install failed"

# --- 安装中文语言包并设置 Locale ---
# 安装语言包
USER root
RUN apt-get update && apt-get install -y --no-install-recommends language-pack-zh-hans && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# 设置环境变量
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
# 切换回之前的用户
USER ${USER_NAME}

#################################################
# 最终配置
#################################################
# 暴露端口
EXPOSE 22
# 保持此端口（如果需要）
EXPOSE 28970

# 设置默认用户和工作目录 (容器启动后生效)
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# systemd 将由基础镜像的 ENTRYPOINT/CMD 启动

# 设置时区 (通过 ENV)
ENV TZ=Asia/Shanghai

# 先安装基础工具
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates gnupg curl

# 添加阿里云 GPG 密钥
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://mirrors.aliyun.com/ubuntu/dists/noble/Release.gpg | gpg --dearmor -o /etc/apt/keyrings/aliyun-ubuntu.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/aliyun-ubuntu.gpg] http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb [signed-by=/etc/apt/keyrings/aliyun-ubuntu.gpg] http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [signed-by=/etc/apt/keyrings/aliyun-ubuntu.gpg] http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [signed-by=/etc/apt/keyrings/aliyun-ubuntu.gpg] http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list

# 添加配置以保留 apt 缓存目录和使用 keyrings 目录
RUN mkdir -p /etc/apt/apt.conf.d/ && \
    echo 'APT::Update::Post-Invoke-Success { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/99fixpostrm && \
    echo 'Dir::Etc::TrustedParts "/etc/apt/keyrings/";' > /etc/apt/apt.conf.d/99keyrings