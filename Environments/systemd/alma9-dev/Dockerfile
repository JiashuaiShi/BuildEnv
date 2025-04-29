# 使用指定的 AlmaLinux 9 init 镜像
FROM almalinux/9-init:9.5-20250411

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Refined AlmaLinux 9 dev environment with systemd"

# ARG for setup mode
ARG SETUP_MODE=systemd

# --- Run Unified Common User Setup Script ---
# 这个脚本会处理: 安装基础工具 (sudo, zsh, sshd - but no config, etc.),
# 创建用户/组, 配置sudo, 创建基础目录
COPY scripts/unified-common-setup.sh /tmp/
RUN chmod +x /tmp/unified-common-setup.sh && \
    export SETUP_MODE=${SETUP_MODE} && \
    /tmp/unified-common-setup.sh && \
    rm /tmp/unified-common-setup.sh

# --- 系统基础设置 (补充安装) ---
# 更新系统并安装 epel-release (如果脚本未安装，这里需要)
RUN dnf -y update && \
    if ! rpm -q epel-release; then dnf -y install epel-release; fi && \
    dnf config-manager --set-enabled crb && \
    dnf -y install dnf-utils # 安装 dnf-utils 如果需要
    # 其他基础工具已由脚本安装

# --- SSH Configuration (Systemd specific) ---
# unified-common-setup.sh skips config for systemd mode
# Apply necessary SSH config for systemd environment
RUN sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config # Keep root login disabled

# 定义构建参数 (用户相关 ARG，虽然脚本内目前硬编码)
ARG USER_NAME=shijiashuai
ARG USER_ID=2034
ARG GROUP_NAME=lush-dev
ARG GROUP_ID=2000
ARG USER_PASSWORD=phoenix2024

# 启用 sshd 服务 (systemd)
RUN systemctl enable sshd

# --- 开发环境安装 (保持不变) ---
# ... (C++, Java, Python, etc. install sections remain the same) ...

#################################################
# C++ 开发环境
#################################################
RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install \
        cmake \
        ninja-build \
        valgrind \
        clang \
        llvm \
        lldb \
        python3-devel \
        libasan \
        libtsan \
        libubsan \
        zlib-devel \
        ncurses-devel \
        bzip2-devel \
        xz-devel \
        autoconf \
        automake \
        libtool \
    && dnf clean all

#################################################
# Java 开发环境 (保留 AlmaLinux 方式)
#################################################
# 安装 JDK 和 Maven (这些在仓库中可用)
RUN dnf -y install java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel maven && \
    dnf clean all

# 手动安装 Gradle
ENV GRADLE_VERSION=8.6
ENV GRADLE_HOME=/opt/gradle
RUN dnf -y install unzip && \
    mkdir -p ${GRADLE_HOME} && \
    cd /tmp && \
    curl -LO https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
    ln -s /opt/gradle-${GRADLE_VERSION} ${GRADLE_HOME} && \
    ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle && \
    rm gradle-${GRADLE_VERSION}-bin.zip && \
    # 验证安装结果
    gradle --version || echo "Gradle installed but not in PATH"

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
# Python 开发环境 (系统级)
#################################################
# unified-common-setup.sh 已安装 python3-pip
RUN dnf -y install python3-devel && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir virtualenv && \
    dnf clean all

#################################################
# 其他开发工具 (Go, Rust)
#################################################
RUN dnf -y install golang rust cargo && \
    dnf clean all

# --- 工具配置 (保持不变) ---
COPY Environments/systemd/alma9-dev/jdk_switcher.sh /usr/local/bin/jdk
RUN chmod +x /usr/local/bin/jdk

# --- 安装中文语言包并设置默认 Locale ---
# (Moved before USER switch to run as root)
RUN dnf -y install glibc-langpack-zh && dnf clean all
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

# --- 用户特定环境配置 (保持不变) ---
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

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
    $HOME/miniconda/bin/conda config --set remote_max_retries 10

# 安装 oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true && \
    sed -i 's/^plugins=(git)/plugins=(git sudo maven gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true

# JDK Aliases
RUN echo -e '\n# JDK Aliases' >> $HOME/.bashrc && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.bashrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.bashrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.bashrc
RUN echo -e '\n# JDK Aliases' >> $HOME/.zshrc && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc

# Custom PATH
RUN echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:\$PATH\"" >> $HOME/.bashrc && \
    echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:\$PATH\"" >> $HOME/.zshrc

# --- Install Python Packages using Conda's pip ---
RUN $HOME/miniconda/bin/pip install --no-cache-dir matplotlib psrecord || echo "Miniconda pip install failed"

# --- 最终镜像配置 (保持不变) ---
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
EXPOSE 22
# ENTRYPOINT/CMD is provided by the base image (systemd)