# 使用标准的 AlmaLinux 9 镜像
FROM almalinux:9

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Refined AlmaLinux 9 dev environment (Supervisord)"

# ARG for setup mode
ARG SETUP_MODE=supervisord

# --- Run Unified Common User Setup Script ---
# 这个脚本会处理: 安装基础工具 (sudo, zsh, sshd, supervisor, etc.),
# 创建用户/组, 配置SSH和sudo, 创建基础目录
COPY scripts/unified-common-setup.sh /tmp/
RUN chmod +x /tmp/unified-common-setup.sh && \
    export SETUP_MODE=${SETUP_MODE} && \
    /tmp/unified-common-setup.sh && \
    rm /tmp/unified-common-setup.sh

# --- Ensure EPEL and CRB are enabled before installing dev tools ---
RUN dnf -y install epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf clean all

# --- 系统基础设置 (如有必要，可在 setup 脚本后补充安装) ---
# unified-common-setup.sh 已安装许多基础工具，这里可能不需要重复安装
# RUN dnf -y update && ...
# RUN dnf -y install dnf-utils ...

# --- 开发环境安装 (保留 C++, Java, Python 等安装步骤) ---

#################################################
# C++ 开发环境
#################################################
# 使用 groupinstall 安装基础开发工具，并补充必要的库和工具
# 确保 Development Tools 和其他依赖已安装
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
# Java 开发环境
#################################################
RUN dnf -y install java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel maven gradle && \
    dnf clean all

# 配置 Java alternatives (保持不变)
RUN for version in 8 11 17; do \
        update-alternatives --install /usr/bin/java java "/usr/lib/jvm/java-${version}-openjdk/bin/java" ${version}0 || true && \
        update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/java-${version}-openjdk/bin/javac" ${version}0 || true && \
        update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/java-${version}-openjdk/bin/jar" ${version}0 || true && \
        update-alternatives --install /usr/bin/javadoc javadoc "/usr/lib/jvm/java-${version}-openjdk/bin/javadoc" ${version}0 || true; \
    done
# 设置默认 JDK 版本为 11 (保持不变)
RUN update-alternatives --set java /usr/lib/jvm/java-11-openjdk/bin/java || true && \
    update-alternatives --set javac /usr/lib/jvm/java-11-openjdk/bin/javac || true && \
    update-alternatives --set jar /usr/lib/jvm/java-11-openjdk/bin/jar || true && \
    update-alternatives --set javadoc /usr/lib/jvm/java-11-openjdk/bin/javadoc || true

# 设置 JAVA_HOME 环境变量 (保持不变)
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

# --- 工具配置 ---
# 配置 supervisor
COPY Environments/alma9/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# 复制并设置 JDK 切换脚本 (保持不变)
COPY Environments/alma9/jdk_switcher.sh /usr/local/bin/jdk
RUN chmod +x /usr/local/bin/jdk

# --- 用户特定环境配置 ---
# 切换到普通用户 (unified-common-setup.sh 已创建)
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装 Miniconda (保持不变)
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

# 安装 oh-my-zsh 及常用插件 (保持不变, unified-common-setup.sh 已安装 zsh)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true && \
    # 安装常用插件
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true && \
    # 启用插件 (保留 conda, maven, gradle 等实用插件)
    sed -i 's/^plugins=(git)/plugins=(git sudo maven gradle conda zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true

# 添加 JDK 切换别名到 .bashrc 和 .zshrc (保持不变)
RUN echo -e '\n# JDK Aliases' >> $HOME/.bashrc && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.bashrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.bashrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.bashrc
RUN echo -e '\n# JDK Aliases' >> $HOME/.zshrc && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc

# 添加自定义工具到 PATH (保持不变)
RUN echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:\$PATH\"" >> $HOME/.bashrc && \
    echo "export PATH=\"/data-lush/lush-dev/${USER_NAME}/build-tools/apps:\$PATH\"" >> $HOME/.zshrc

# 安装用户指定的 Python 包 (保持不变)
RUN $HOME/miniconda/bin/pip install --no-cache-dir matplotlib psrecord || echo "Miniconda pip install failed"

# --- 最终镜像配置 ---
# 切换回 root 以便设置 CMD
USER root

# 暴露 SSH 端口
EXPOSE 22

# 设置容器启动命令
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# 默认工作目录设置（影响进入容器时的默认目录）
WORKDIR /home/shijiashuai