# 使用CentOS 7作为基础镜像
FROM centos:7.9.2009

# 设置维护者信息
LABEL maintainer="shijiashuai" description="CentOS 7 with C++ development tools" organization="BGI"

# Switch CentOS repositories to vault.centos.org
RUN sed -i -e 's/mirrorlist/#mirrorlist/g' -e 's/^#baseurl=http:\\/\\/mirror\\.centos\\.org/baseurl=http:\\/\\/vault\\.centos\\.org/g' /etc/yum.repos.d/CentOS-*.repo

# 更新系统并安装C++开发所需的工具和库
# 更新系统并安装C++开发所需的工具和库
RUN yum update -y && \
	yum install -y sudo openssh-server zsh && \
    yum groupinstall -y "Development Tools" && \
    yum install -y gcc-c++ cmake make git wget boost-devel && \
    yum clean all

# 创建SSH配置目录
RUN mkdir /var/run/sshd

# 设置root用户的密码（如果需要）
RUN echo 'root:0306' | chpasswd

# 允许root用户通过SSH登录
RUN sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 将SSH的登录提示关闭
RUN sed -i 's/.*UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# 暴露SSH的默认端口
EXPOSE 22

# 创建 lush-dev 用户组并指定 GID
RUN groupadd -g 2000 lush-dev

# 创建 shijiashuai 用户并指定 UID 以及其所属的组
RUN useradd -m -u 2034 -g lush-dev shijiashuai

# 将 shijiashuai 用户添加到 wheel 组
RUN usermod -aG wheel shijiashuai

# 设置 shijiashuai 用户的密码
RUN echo 'shijiashuai:0306' | chpasswd

# 将 shijiashuai 用户添加到 sudo 组
# RUN usermod -aG sudo shijiashuai

# 允许 sudo 组的所有用户无需密码执行 sudo 命令
# RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 将工作目录的所有权赋予 shijiashuai 用户
RUN mkdir /workspace && chown -R shijiashuai:lush-dev /workspace

# 切换到 shijiashuai 用户
USER shijiashuai

# 设置工作目录
WORKDIR /workspace

# 安装 oh-my-zsh
# RUN sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# 克隆 oh-my-zsh 的仓库
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 声明 VOLUME，为镜像创建挂载点
VOLUME ["/data", "/data1"]

# 设置启动SSH服务和zsh的命令
CMD ["/bin/sh", "-c", "/usr/sbin/sshd -D & exec zsh"]