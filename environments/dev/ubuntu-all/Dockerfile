FROM ubuntu:24.04
# FROM shuai/ubuntu:24.04

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="统一开发环境 - C++/Java多版本"

# 接收构建参数

# 在构建时设置代理环境变量

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

# 安装基础组件
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    ca-certificates \
    gnupg \
    wget \
    gpg \
    curl \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# --- Run Common User Setup Script ---
COPY scripts/common-user-setup.sh /tmp/
RUN chmod +x /tmp/common-user-setup.sh && \
    /tmp/common-user-setup.sh && \
    rm /tmp/common-user-setup.sh

#################################################
# C++开发环境安装部分
#################################################

# 分步安装基础工具
# Note: sudo, git already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    build-essential \
    cmake \
    gdb \
    git \
    ninja-build \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 分步安装编译相关工具
# Note: locales-all already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    autoconf \
    automake \
    libtool \
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

# 安装其他C++工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    valgrind \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# Java开发环境安装部分
#################################################

# 安装OpenJDK多个版本
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 配置Java alternatives
RUN mkdir -p /etc/alternatives && \
    for version in 8 11 17; do \
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

# 安装Java开发工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    maven \
    gradle \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# Python开发环境安装部分
#################################################

# 安装Python相关工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

#################################################
# 通用开发工具安装
#################################################

# 安装通用开发工具（除了SSH相关）
# Note: zsh, supervisor already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    vim \
    neovim \
    htop \
    less \
    tmux \
    perl \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# --- Add Netdata Installation ---
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y curl && \
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait --non-interactive || echo "Netdata installation skipped or failed"

# 配置 supervisor (基础目录已由脚本创建)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# SSH服务安装和配置 (已由脚本完成)
# 设置语言环境 (已由脚本完成)
# 清理代理设置，确保最终镜像不包含代理

#################################################
# 工具配置部分
#################################################

# 确保C++17支持
RUN if [ -f /usr/bin/g++-13 ]; then \
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
        g++ --version; \
    fi

# 创建JDK版本切换脚本
RUN echo '#!/bin/bash' > /usr/local/bin/jdk && \
    echo 'case "$1" in' >> /usr/local/bin/jdk && \
    echo '  "8")' >> /usr/local/bin/jdk && \
    echo '    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /usr/local/bin/jdk && \
    echo '    export PATH=$JAVA_HOME/bin:$PATH' >> /usr/local/bin/jdk && \
    echo '    echo "已切换到 JDK 8"' >> /usr/local/bin/jdk && \
    echo '    ;;' >> /usr/local/bin/jdk && \
    echo '  "11")' >> /usr/local/bin/jdk && \
    echo '    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /usr/local/bin/jdk && \
    echo '    export PATH=$JAVA_HOME/bin:$PATH' >> /usr/local/bin/jdk && \
    echo '    echo "已切换到 JDK 11"' >> /usr/local/bin/jdk && \
    echo '    ;;' >> /usr/local/bin/jdk && \
    echo '  "17")' >> /usr/local/bin/jdk && \
    echo '    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /usr/local/bin/jdk && \
    echo '    export PATH=$JAVA_HOME/bin:$PATH' >> /usr/local/bin/jdk && \
    echo '    echo "已切换到 JDK 17"' >> /usr/local/bin/jdk && \
    echo '    ;;' >> /usr/local/bin/jdk && \
    echo '  *)' >> /usr/local/bin/jdk && \
    echo '    echo "用法: jdk [版本]"' >> /usr/local/bin/jdk && \
    echo '    echo "可用版本: 8, 11, 17"' >> /usr/local/bin/jdk && \
    echo '    echo "当前版本: $(java -version 2>&1 | head -n 1)"' >> /usr/local/bin/jdk && \
    echo '    ;;' >> /usr/local/bin/jdk && \
    echo 'esac' >> /usr/local/bin/jdk && \
    chmod +x /usr/local/bin/jdk

# 创建JDK别名用于快速切换
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> /etc/bash.bashrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> /etc/bash.bashrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> /etc/bash.bashrc

#################################################
# 用户与权限设置 (大部分已由脚本完成)
#################################################

# 切换到普通用户 (脚本已创建用户)
USER shijiashuai
WORKDIR /home/shijiashuai

#################################################
# 用户环境配置
#################################################

# 安装 Miniconda
RUN wget -q -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x /tmp/miniconda.sh && \
    export CONDA_DISABLE_PROGRESS_BARS=1 && \
    export PYTHONIOENCODING=utf8 && \
    export PYTHONUNBUFFERED=1 && \
    bash /tmp/miniconda.sh -b -p $HOME/miniconda && \
    rm -f /tmp/miniconda.sh && \
    $HOME/miniconda/bin/conda config --set always_yes yes && \
    $HOME/miniconda/bin/conda config --set auto_activate_base false && \
    $HOME/miniconda/bin/conda config --set ssl_verify false && \
    $HOME/miniconda/bin/conda config --set remote_read_timeout_secs 600 && \
    $HOME/miniconda/bin/conda config --set remote_connect_timeout_secs 60 && \
    $HOME/miniconda/bin/conda config --set concurrent_download_threads 1 && \
    $HOME/miniconda/bin/conda config --set remote_max_retries 10 && \
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc && \
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.zshrc && \
    # Ensure the user owns the config files after modification
    chown shijiashuai:lush-dev $HOME/.bashrc $HOME/.zshrc

# 安装oh-my-zsh和插件 (Zsh 已由脚本安装)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true && \
    sed -i 's/plugins=(git)/plugins=(git maven gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true && \
    # Ensure the user owns the config file after modification
    chown shijiashuai:lush-dev $HOME/.zshrc

# 添加JDK切换别名
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc

# 添加自定义工具到PATH
RUN echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> /home/shijiashuai/.zshrc && \
    echo 'export PATH="/data-lush/lush-dev/shijiashuai/build-tools/apps:$PATH"' >> /home/shijiashuai/.bashrc && \
    chown shijiashuai:lush-dev /home/shijiashuai/.zshrc /home/shijiashuai/.bashrc

# --- Install Python Packages using Conda's pip ---
RUN if [ -x "$HOME/miniconda/bin/pip" ]; then \
        $HOME/miniconda/bin/pip install --no-cache-dir matplotlib psrecord; \
    else \
        echo "Miniconda pip not found, skipping matplotlib/psrecord installation."; \
    fi

# 切换回root用户完成最终配置
USER root

# Expose Netdata port (optional)
EXPOSE 19999

# 开放SSH端口 (已由脚本完成)
EXPOSE 22

# 设置容器启动命令
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# 注意：不在这里切换用户，让 supervisord 以 root 运行
# 默认工作目录设置（影响进入容器时的默认目录）
WORKDIR /home/shijiashuai