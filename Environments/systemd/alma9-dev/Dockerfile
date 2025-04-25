# 使用指定的 AlmaLinux 9 init 镜像
FROM almalinux/9-init:9.5-20250411

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Refined AlmaLinux 9 dev environment with systemd"

# --- 系统基础设置 ---
# 更新系统并安装 epel-release
RUN dnf -y update && \
    dnf -y install epel-release && \
    # 启用 CRB (CodeReady Builder) 源，EPEL 可能需要其中的包
    dnf config-manager --set-enabled crb && \
    dnf clean all

# 安装基础工具和依赖 (包括来自 EPEL 的)
RUN dnf -y install \
    sudo \
    dnf-utils \
    # ca-certificates, gnupg2, wget, curl, tar, etc. 已经作为基础镜像或 epel-release 依赖安装
    gzip \
    bzip2 \
    xz \
    zip \
    unzip \
    git \
    vim \
    neovim \
    tmux \
    htop \
    less \
    perl \
    zsh \
    dos2unix \
    rsync \
    openssh-server \
    && dnf clean all

# --- 安全与用户配置 ---
# 配置 SSH (允许 root 登录和密码认证，适用于开发环境)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 定义构建参数 (与 Ubuntu 统一命名)
ARG USER_NAME=shijiashuai
ARG USER_ID=2034
ARG GROUP_NAME=lush-dev
ARG GROUP_ID=2000
ARG USER_PASSWORD=phoenix2024
ARG ROOT_PASSWORD=phoenix2024

# 创建用户、组，设置密码，并配置无密码 sudo (使用 /etc/sudoers.d/)
RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} || echo "Group ${GROUP_NAME} (${GROUP_ID}) already exists." && \
    useradd -m -d /home/${USER_NAME} -s /bin/zsh -u ${USER_ID} -g ${GROUP_NAME} ${USER_NAME} && \
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && \
    echo "root:${ROOT_PASSWORD}" | chpasswd && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}-nopasswd && \
    chmod 0440 /etc/sudoers.d/${USER_NAME}-nopasswd && \
    # 创建并授权工作区目录
    mkdir -p /workspace && chown -R ${USER_NAME}:${GROUP_NAME} /workspace

# 启用 sshd 服务 (systemd)
RUN systemctl enable sshd

# --- 开发环境安装 ---

#################################################
# C++ 开发环境
#################################################
# 使用 groupinstall 安装基础开发工具，并补充必要的库和工具
RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install \
        # 常用工具
        cmake \
        ninja-build \
        valgrind \
        # Clang 工具链
        clang \
        llvm \
        lldb \
        # Python 绑定开发需要
        python3-devel \
        # Sanitizers
        libasan \
        libtsan \
        libubsan \
        # 关键的 -devel 包 (来自原 Alma 构建脚本的优点)
        zlib-devel \
        ncurses-devel \
        bzip2-devel \
        xz-devel \
        # 额外的构建工具 (来自原 Alma 构建脚本)
        autoconf \
        automake \
        libtool \
    && dnf clean all
# 可选：设置特定 g++ 版本 (如果需要)
# RUN update-alternatives ...

#################################################
# Java 开发环境 (保留 AlmaLinux 方式)
#################################################
RUN dnf -y install java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel maven gradle && \
    dnf clean all

# 配置 Java alternatives (使用 AlmaLinux/RHEL 标准路径)
RUN for version in 8 11 17; do \
        update-alternatives --install /usr/bin/java java "/usr/lib/jvm/java-${version}-openjdk/bin/java" ${version}0 || true && \
        update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/java-${version}-openjdk/bin/javac" ${version}0 || true && \
        update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/java-${version}-openjdk/bin/jar" ${version}0 || true && \
        update-alternatives --install /usr/bin/javadoc javadoc "/usr/lib/jvm/java-${version}-openjdk/bin/javadoc" ${version}0 || true; \
    done

# 设置默认 JDK 版本为 11
RUN update-alternatives --set java /usr/lib/jvm/java-11-openjdk/bin/java || true && \
    update-alternatives --set javac /usr/lib/jvm/java-11-openjdk/bin/javac || true && \
    update-alternatives --set jar /usr/lib/jvm/java-11-openjdk/bin/jar || true && \
    update-alternatives --set javadoc /usr/lib/jvm/java-11-openjdk/bin/javadoc || true

# 设置 JAVA_HOME 环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

#################################################
# Python 开发环境 (系统级 + 用户级 Miniconda)
#################################################
# 安装系统级 Python 和 pip/venv 工具
RUN dnf -y install python3 python3-pip python3-devel && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir virtualenv && \
    dnf clean all

#################################################
# 其他开发工具 (Go, Rust)
#################################################
RUN dnf -y install golang rust cargo && \
    # sbt/netdata 安装可能需要额外步骤，暂时省略
    dnf clean all

# --- 工具配置 ---
# 复制并设置 JDK 切换脚本
COPY --chown=root:root jdk_switcher.sh /usr/local/bin/jdk
RUN chmod +x /usr/local/bin/jdk

# --- 用户特定环境配置 ---
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 安装 Miniconda (借鉴 Ubuntu 的优秀实践)
RUN wget -q -O /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x /tmp/miniconda.sh && \
    # 使用 -b 批处理模式, -p 指定安装路径
    bash /tmp/miniconda.sh -b -p $HOME/miniconda && \
    rm -f /tmp/miniconda.sh && \
    # 初始化 conda (bash 和 zsh)
    $HOME/miniconda/bin/conda init bash && \
    $HOME/miniconda/bin/conda init zsh && \
    # 配置 conda (常用设置)
    $HOME/miniconda/bin/conda config --set always_yes yes && \
    $HOME/miniconda/bin/conda config --set auto_activate_base false && \
    $HOME/miniconda/bin/conda config --set ssl_verify false && \
    $HOME/miniconda/bin/conda config --set remote_read_timeout_secs 600 && \
    $HOME/miniconda/bin/conda config --set remote_connect_timeout_secs 60 && \
    $HOME/miniconda/bin/conda config --set remote_max_retries 10

# 安装 oh-my-zsh 及常用插件 (借鉴 Ubuntu 的增强配置)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true && \
    # 安装常用插件
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true && \
    # 启用插件 (保留 conda, maven, gradle 等实用插件)
    sed -i 's/^plugins=(git)/plugins=(git sudo maven gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true

# 添加 JDK 切换别名到 .bashrc 和 .zshrc (确保两边都有)
RUN echo -e '\n# JDK Aliases' >> $HOME/.bashrc && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.bashrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.bashrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.bashrc
RUN echo -e '\n# JDK Aliases' >> $HOME/.zshrc && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc

# 添加自定义工具到 PATH (保持路径一致性，已修复)
RUN echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:\$PATH\"" >> $HOME/.bashrc && \
    echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:\$PATH\"" >> $HOME/.zshrc

# 安装用户指定的 Python 包 (使用 Conda 环境的 pip)
RUN $HOME/miniconda/bin/pip install --no-cache-dir matplotlib psrecord || echo "Miniconda pip install failed"

# --- 最终镜像配置 ---
# 暴露 SSH 端口
EXPOSE 22

# 设置默认用户和工作目录
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# ENTRYPOINT/CMD 由基础镜像提供 (systemd)