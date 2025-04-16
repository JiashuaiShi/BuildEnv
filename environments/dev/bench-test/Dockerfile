FROM ubuntu:24.04

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Comprehensive Dev Environment (C++/Java/Conda)"

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 替换apt源为国内镜像（阿里云）
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \\
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \\
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \\
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \\
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list

# 添加配置以忽略GPG签名验证和修复Post-Invoke脚本问题
RUN mkdir -p /etc/apt/apt.conf.d/ && \\
    echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99allow-unauthenticated && \\
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-unauthenticated && \\
    echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-unauthenticated && \\
    echo 'APT::Update::Post-Invoke-Success { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/99fixpostrm && \\
    echo 'Dir::Etc::TrustedParts "/etc/apt/keyrings/";' > /etc/apt/apt.conf.d/99keyrings && \\
    mkdir -p /etc/apt/keyrings

# 安装基础组件
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    ca-certificates \\
    gnupg \\
    wget \\
    gpg \\
    curl \\
    apt-transport-https \\
    software-properties-common \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# --- Run Common User Setup Script ---
# Assuming the common setup script is in ../../scripts relative to this Dockerfile context
COPY ../../scripts/common-user-setup.sh /tmp/
RUN chmod +x /tmp/common-user-setup.sh && \\
    /tmp/common-user-setup.sh && \\
    rm /tmp/common-user-setup.sh

#################################################
# C++ Build Environment Installation
#################################################

# Install essential C++ build tools
# Note: sudo, git already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    build-essential \\
    cmake \\
    gdb \\
    ninja-build \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# Install other compilation-related tools
# Note: locales-all already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    autoconf \\
    automake \\
    libtool \\
    dos2unix \\
    rsync \\
    tar \\
    xz-utils \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# Install essential development libraries
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    zlib1g-dev \\
    libncurses5-dev \\
    libbz2-dev \\
    liblzma-dev \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# Install GCC toolchain
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    g++-13 \\
    gcc-13 \\
    cpp-13 \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# --- Add Clang Installation --- 
# 分步安装 clang 相关工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    clang \\
    clang-tools \\
    clangd \\
    llvm \\
    lldb \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# --- Add Valgrind (if not already present) ---
# 安装其他C++工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    valgrind \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

#################################################
# Python Environment Installation
#################################################

# Install Python basics
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    python3 \\
    python3-dev \\
    python3-pip \\
    python3-venv \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

#################################################
# Java Environment Installation
#################################################

# 安装OpenJDK多个版本
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    openjdk-8-jdk \\
    openjdk-11-jdk \\
    openjdk-17-jdk \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

# 配置Java alternatives
RUN mkdir -p /etc/alternatives && \\
    for version in 8 11 17; do \\
        if [ -d "/usr/lib/jvm/java-${version}-openjdk-amd64" ]; then \\
            update-alternatives --install /usr/bin/java java "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/java" ${version}0 || true && \\
            update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/javac" ${version}0 || true && \\
            update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/jar" ${version}0 || true && \\
            update-alternatives --install /usr/bin/javadoc javadoc "/usr/lib/jvm/java-${version}-openjdk-amd64/bin/javadoc" ${version}0 || true; \\
        fi \\
    done

# 设置默认JDK版本为JDK 11
RUN if [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then \\
        update-alternatives --set java "/usr/lib/jvm/java-11-openjdk-amd64/bin/java" || true && \\
        update-alternatives --set javac "/usr/lib/jvm/java-11-openjdk-amd64/bin/javac" || true && \\
        update-alternatives --set jar "/usr/lib/jvm/java-11-openjdk-amd64/bin/jar" || true && \\
        update-alternatives --set javadoc "/usr/lib/jvm/java-11-openjdk-amd64/bin/javadoc" || true; \\
    fi

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# 安装Java开发工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    maven \\
    gradle \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

#################################################
# Common Tools Installation
#################################################

# Install common tools (add neovim, tmux)
# Note: zsh, supervisor already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    vim \\
    neovim \\
    htop \\
    less \\
    tmux \\
    && rm -rf /var/lib/apt/lists/* && \\
    apt-get clean || true

#################################################
# Final Configurations
#################################################

# Configure supervisor (assuming supervisord.conf is in the same directory)
# Note: Base directory /etc/supervisor/conf.d created by common script
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Ensure C++17 support using GCC 13
RUN if [ -f /usr/bin/g++-13 ]; then \\
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \\
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \\
        g++ --version; \\
    fi

# --- Add Java Version Switching Script/Aliases ---
# 创建JDK版本切换脚本
RUN echo '#!/bin/bash' > /usr/local/bin/jdk && \\
    echo 'case "$1" in' >> /usr/local/bin/jdk && \\
    echo '  "8")' >> /usr/local/bin/jdk && \\
    echo '    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /usr/local/bin/jdk && \\
    echo '    export PATH=$JAVA_HOME/bin:$PATH' >> /usr/local/bin/jdk && \\
    echo '    echo "已切换到 JDK 8"' >> /usr/local/bin/jdk && \\
    echo '    ;;' >> /usr/local/bin/jdk && \\
    echo '  "11")' >> /usr/local/bin/jdk && \\
    echo '    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /usr/local/bin/jdk && \\
    echo '    export PATH=$JAVA_HOME/bin:$PATH' >> /usr/local/bin/jdk && \\
    echo '    echo "已切换到 JDK 11"' >> /usr/local/bin/jdk && \\
    echo '    ;;' >> /usr/local/bin/jdk && \\
    echo '  "17")' >> /usr/local/bin/jdk && \\
    echo '    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /usr/local/bin/jdk && \\
    echo '    export PATH=$JAVA_HOME/bin:$PATH' >> /usr/local/bin/jdk && \\
    echo '    echo "已切换到 JDK 17"' >> /usr/local/bin/jdk && \\
    echo '    ;;' >> /usr/local/bin/jdk && \\
    echo '  *)' >> /usr/local/bin/jdk && \\
    echo '    echo "用法: jdk [版本]"' >> /usr/local/bin/jdk && \\
    echo '    echo "可用版本: 8, 11, 17"' >> /usr/local/bin/jdk && \\
    echo '    echo "当前版本: $(java -version 2>&1 | head -n 1)"' >> /usr/local/bin/jdk && \\
    echo '    ;;' >> /usr/local/bin/jdk && \\
    echo 'esac' >> /usr/local/bin/jdk && \\
    chmod +x /usr/local/bin/jdk

# 创建JDK别名用于快速切换 (Add to user profile? common script might handle .bashrc/.zshrc)
# Let's add to /etc/profile.d for system-wide effect for login shells
RUN echo 'alias jdk8="source /usr/local/bin/jdk 8"' > /etc/profile.d/jdk_aliases.sh && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> /etc/profile.d/jdk_aliases.sh && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> /etc/profile.d/jdk_aliases.sh

# Switch to user (already created by common script)
USER shijiashuai
WORKDIR /home/shijiashuai

# --- Add Conda Installation --- 
# 安装Miniconda - 使用更可靠的下载方式和超时设置
RUN curl -s -L --connect-timeout 30 --max-time 300 -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh || \\
    wget -q --timeout=300 -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh || \\
    echo "Failed to download Miniconda"

# 安装并配置Miniconda - 简化安装过程
RUN if [ -f /tmp/miniconda.sh ]; then \\
        bash /tmp/miniconda.sh -b -p $HOME/miniconda && \\
        rm -f /tmp/miniconda.sh && \\
        export PATH="$HOME/miniconda/bin:$PATH" && \\
        echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc && \\
        echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.zshrc && \\
        $HOME/miniconda/bin/conda config --set auto_activate_base false && \\
        $HOME/miniconda/bin/conda config --set ssl_verify false && \\
        $HOME/miniconda/bin/conda config --set remote_read_timeout_secs 600 && \\
        $HOME/miniconda/bin/conda config --set remote_connect_timeout_secs 60 && \\
        $HOME/miniconda/bin/conda config --set remote_max_retries 10; \\
        # Ensure user owns files modified in this step
        chown shijiashuai:lush-dev $HOME/.bashrc $HOME/.zshrc; \
    fi

# --- Oh My Zsh installation/configuration (Optional - refine based on common script) ---
# Assuming common script installs base zsh & oh-my-zsh, just add plugins
RUN if [ -d "$HOME/.oh-my-zsh" ]; then \
        mkdir -p ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins && \
        (git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true) && \
        (git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true) && \
        if [ -f $HOME/.zshrc ]; then \
            sed -i 's/plugins=(git)/plugins=(git maven gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true; \
            # Ensure user owns the modified .zshrc
            chown shijiashuai:lush-dev $HOME/.zshrc; \
        fi; \
    fi

# --- Add user customizations like .bashrc, .zshrc modifications if needed ---
# Example: Adding custom tools path if not handled elsewhere
# RUN echo 'export PATH="/path/to/custom/tools:$PATH"' >> $HOME/.zshrc && chown shijiashuai:lush-dev $HOME/.zshrc

# Switch back to root for entrypoint
USER root

# Expose SSH port (already configured by common script)
EXPOSE 22

# Set container entrypoint to run supervisord
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Default workdir when exec-ing into container
WORKDIR /home/shijiashuai 