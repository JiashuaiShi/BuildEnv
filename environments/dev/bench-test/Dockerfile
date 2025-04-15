FROM ubuntu:24.04

# 设置镜像元信息
LABEL maintainer="shijiashuai" description="Benchmark Testing Environment"

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
# Benchmark Specific Tools Installation (Placeholder)
#################################################

# Add RUN commands here to install necessary benchmark tools, libraries, or dependencies
# Example:
# RUN apt-get update && apt-get install -y some-benchmark-tool another-lib
# RUN pip3 install some-python-benchmark-lib

#################################################
# Common Tools Installation
#################################################

# Install minimal common tools
# Note: zsh, supervisor already installed by common script
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || true && \\
    apt-get install -y --no-install-recommends --allow-unauthenticated \\
    vim \\
    htop \\
    less \\
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

# Switch to user (already created by common script)
USER shijiashuai
WORKDIR /home/shijiashuai

# --- Oh My Zsh installation (Optional - if needed and not handled by common script) ---
# RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true

# --- Add user customizations like .bashrc, .zshrc modifications if needed ---

# Switch back to root for entrypoint
USER root

# Expose SSH port (already configured by common script)
EXPOSE 22

# Set container entrypoint to run supervisord
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Default workdir when exec-ing into container
WORKDIR /home/shijiashuai 