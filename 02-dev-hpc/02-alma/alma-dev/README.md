# AlmaLinux HPC 开发环境 (`alma-dev`)

本环境基于 `alma-base` 基础镜像构建，提供了一个功能完备的、用于 C++ 和 Java 高性能计算（HPC）开发的容器化环境。

## 环境特性

- **操作系统**: AlmaLinux 9
- **基础服务**: 已配置好 SSH 和 Supervisor。
- **C++ 工具链**: 
    - GCC (通过 `Development Tools` 安装)
    - Clang
    - CMake
    - GDB
    - Valgrind
- **Java 工具链**:
    - OpenJDK 17
    - Maven
- **常用工具**:
    - Git
    - Vim
    - htop
    - zsh (配合 oh-my-zsh)

## 首次使用：构建与启动

请按照以下步骤在您的宿主机上构建和启动本开发环境。

### 1. 配置密码

在第一次构建前，您需要配置开发用户的密码。脚本会从 `.env` 文件中读取密码。

- 复制或重命名 `.env.example` 为 `.env` (如果 `.env.example` 存在)。
- 如果 `.env` 文件不存在，请手动创建它，并填入以下内容：

```env
# 请替换为您自己的安全密码
DEV_PASSWORD=your_secure_password_here
```

**重要**: 此密码将用于 `alma-base` 镜像的构建，为容器内的 `shijiashuai` 用户设置密码。

### 2. 执行构建脚本

在当前 (`alma-dev`) 目录下，运行构建脚本：

```bash
./build.sh
```

此脚本会自动完成以下工作：
1.  检查 `alma-base:latest` 基础镜像是否存在。
2.  如果不存在，它将使用 `.env` 文件中的密码构建 `alma-base` 镜像。
3.  基于 `alma-base:latest` 构建 `alma-dev:latest` 开发环境镜像。

### 3. 启动容器

构建成功后，运行启动脚本：

```bash
./start.sh
```

该命令会通过 `docker-compose up -d` 在后台启动容器。

## 如何使用

您可以通过多种方式与容器交互。

### 通过 SSH 连接

使用 `dev-cli.sh` 脚本可以方便地连接到容器：

```bash
./dev-cli.sh ssh
```

或者手动连接：

```bash
ssh shijiashuai@localhost -p 28974
```

### 在容器内执行命令

如果您想在不进入交互式 Shell 的情况下执行单条命令，可以使用 `exec`：

```bash
./dev-cli.sh exec "ls -la /workspace"
```

### 管理容器生命周期

`dev-cli.sh` 脚本提供了完整的容器管理功能：

- **查看状态**: `./dev-cli.sh status`
- **查看日志**: `./dev-cli.sh logs`
- **停止容器**: `./dev-cli.sh stop`
- **停止并删除容器**: `./dev-cli.sh down`
- **重启容器**: `./dev-cli.sh restart`

使用 `./dev-cli.sh help` 查看所有可用命令。

## 目录与文件说明

- `Dockerfile`: 构建 `alma-dev` 镜像，安装所有开发工具。
- `docker-compose.yaml`: 定义容器的服务、端口映射、卷挂载等。
- `.env`: 存储敏感信息，如用户密码（此文件不应提交到 Git）。
- `build.sh`: 智能构建脚本，负责分层构建镜像。
- `start.sh`: 启动容器的便捷脚本。
- `dev-cli.sh`: 用于管理和与容器交互的命令行工具。
