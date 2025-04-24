# 使用 AlmaLinux 9 作为基础镜像
FROM almalinux/9-init:9.5-20250411

# 设置镜像的元信息
LABEL maintainer="shijiashuai" description="AlmaLinux 9 for C++/Java/Python dev with systemd"

#################################################
# 基础系统配置
#################################################

# 安装基础系统组件
RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install --allowerasing \
    sudo \
    wget \
    curl \
    ca-certificates \
    gnupg \
    openssh-server \
    && dnf clean all

# 设置 SSH 和用户信息
# ssh-keygen -A is handled by sshd.service
RUN echo 'root:0306' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    groupadd -g 2000 lush-dev && \
    useradd -m -d /home/shijiashuai -s /bin/zsh -u 2034 -g lush-dev shijiashuai && \
    echo 'shijiashuai:phoenix2024' | chpasswd && \
    echo '%lush-dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p /workspace && chown -R shijiashuai:lush-dev /workspace

# 使用 systemd 启用 sshd 服务
RUN systemctl enable sshd

#################################################
# C++开发环境安装部分
#################################################
# 启用 CodeReady Builder (CRB) 仓库，它包含很多开发包的依赖
RUN dnf config-manager --set-enabled crb || \
    echo "Could not enable CRB repository. Trying to install development tools anyway..."

RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install \
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
    xz \
    zlib-devel \
    ncurses-devel \
    bzip2-devel \
    xz-devel \
    # Clang
    clang \
    llvm \
    # 其他工具
    valgrind \
    && dnf clean all

#################################################
# Python开发环境安装部分
#################################################
RUN dnf -y install \
    python3 \
    python3-pip \
    python3-devel \
    && dnf clean all

#################################################
# Java开发环境安装部分
#################################################
RUN dnf -y install \
    java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel \
    java-11-openjdk \
    java-11-openjdk-devel \
    java-17-openjdk \
    java-17-openjdk-devel \
    && dnf clean all

# 配置Java alternatives
RUN for version in 8 11 17; do \
        if [ -d "/usr/lib/jvm/java-${version}-openjdk" ]; then \
            update-alternatives --install /usr/bin/java java "/usr/lib/jvm/java-${version}-openjdk/bin/java" ${version}0 || true && \
            update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/java-${version}-openjdk/bin/javac" ${version}0 || true && \
            update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/java-${version}-openjdk/bin/jar" ${version}0 || true && \
            update-alternatives --install /usr/bin/javadoc javadoc "/usr/lib/jvm/java-${version}-openjdk/bin/javadoc" ${version}0 || true; \
        fi \
    done

#################################################
# 工具配置部分
#################################################

# 创建JDK版本切换脚本
COPY --chown=root:root jdk_switcher.sh /usr/local/bin/jdk
RUN chmod +x /usr/local/bin/jdk

# 安装其他开发工具
RUN dnf -y install \
    vim \
    zsh \
    git \
    && dnf clean all

#################################################
# 用户环境配置 (切换到用户)
#################################################
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装 oh-my-zsh
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git .oh-my-zsh && \
    cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc && \
    echo "ZSH_DISABLE_COMPFIX=true" >> .zshrc && \
    # 安装 zsh 插件
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true && \
    sed -i 's/plugins=(git)/plugins=(git maven gradle zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true

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

# 切换回 root 用户进行后续操作
USER root
WORKDIR /

# 开放 SSH 端口
EXPOSE 22

# 设置 VOLUME
VOLUME ["/workspace", "/data", "/data1"]

# 容器启动命令由基础镜像的 systemd 入口点处理
# CMD instruction removed to use base image's default ENTRYPOINT (/usr/sbin/init)
