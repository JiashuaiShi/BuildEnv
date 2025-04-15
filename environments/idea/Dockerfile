FROM shuai/ubuntu-2404:1.0

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Ubuntu开发容器 - 多JDK版本(8/11/17)"

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

# 添加配置以忽略GPG签名验证
RUN mkdir -p /etc/apt/apt.conf.d/ && \
    echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99allow-unauthenticated && \
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-unauthenticated && \
    echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-unauthenticated && \
    echo 'APT::Update::Post-Invoke-Success { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/99fixpostrm

# 安装基础工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    ca-certificates \
    gnupg \
    wget \
    curl \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 安装OpenJDK多个版本
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 安装开发工具
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    git \
    maven \
    gradle \
    vim \
    less \
    sudo \
    zsh \
    openssh-server \
    supervisor \
    locales-all \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean || true

# 设置语言环境
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 清理代理设置，确保最终镜像不包含代理
ENV http_proxy=""
ENV https_proxy=""

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

# 设置默认JDK版本为JDK 11
RUN update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-11-openjdk-amd64/bin/javac
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# 用户与SSH设置
RUN groupadd -g 2000 lush-dev && \
    useradd -m -u 2034 -g lush-dev shijiashuai && \
    echo 'shijiashuai:phoenix2024' | chpasswd && \
    usermod -aG sudo shijiashuai && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /workspace && chown -R shijiashuai:lush-dev /workspace && \
    mkdir -p /data-lush/lush-dev/shijiashuai && \
    chown -R shijiashuai:lush-dev /data-lush && \
    chsh -s /usr/bin/zsh shijiashuai

# SSH配置
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# 切换用户
USER shijiashuai
WORKDIR /home/shijiashuai

# 安装oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true && \
    sed -i 's/plugins=(git)/plugins=(git maven gradle zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc || true && \
    echo 'alias jdk8="source /usr/local/bin/jdk 8"' >> $HOME/.zshrc && \
    echo 'alias jdk11="source /usr/local/bin/jdk 11"' >> $HOME/.zshrc && \
    echo 'alias jdk17="source /usr/local/bin/jdk 17"' >> $HOME/.zshrc && \
    chown shijiashuai:lush-dev $HOME/.zshrc # 确保用户有所有权

# 切回root用户完成剩余配置
USER root

# Supervisor配置
RUN mkdir -p /etc/supervisor/conf.d && \
    mkdir -p /var/log/supervisor && \
    chown root:root /var/log/supervisor # 确保root拥有日志目录
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf # 确保root可读

# 开放SSH端口
EXPOSE 22

# 设置容器启动命令 (由 root 执行)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# 设置默认工作目录和用户 (影响 docker exec)
USER shijiashuai
WORKDIR /home/shijiashuai 