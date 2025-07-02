# NAS 服务与管理环境 (AlmaLinux 9)

本环境基于 AlmaLinux 9，提供了一个预装了 Samba 和 NFS 的网络附加存储 (NAS) 服务与管理平台。

## 环境特性

- **操作系统**: AlmaLinux 9
- **核心服务**:
  - **Samba**: 用于提供与 Windows 兼容的文件共享服务。
  - **NFS**: 用于提供与 Linux/Unix 兼容的文件共享服务。
- **终端环境**: Zsh (with Oh My Zsh, auto-suggestions, syntax-highlighting)
- **基础服务**:
  - OpenSSH 服务器，用于远程管理。
  - Supervisor，用于进程管理。

## 快速使用指南

### 1. 配置环境

首先，复制 `.env.example` 文件为 `.env`，并根据您的需求修改其中的配置。

```bash
cp .env.example .env
```

**必须**修改 `DEV_PASSWORD` 为一个安全的密码。`USER_UID` 和 `GROUP_GID` 应与您宿主机的用户 ID 匹配，以避免文件权限问题。您可以通过 `id -u` 和 `id -g` 命令在您的宿主机上获取这些值。

### 2. 构建与启动

使用目录内提供的脚本来管理容器生命周期。

- **构建镜像**:
  ```bash
  ./build.sh
  ```
- **启动容器** (后台运行):
  ```bash
  ./start.sh
  ```
- **停止容器**:
  ```bash
  ./start.sh stop
  ```
- **重启容器**:
  ```bash
  ./start.sh restart
  ```
- **查看日志**:
  ```bash
  ./start.sh logs
  ```
- **完全清理** (停止并删除容器):
  ```bash
  ./start.sh down
  ```

### 3. 连接与管理

- **通过 SSH 连接**:
  容器的 22 端口已映射到主机的 2225 端口。
  ```bash
  # 使用 dev-cli.sh 脚本 (推荐)
  ./dev-cli.sh ssh

  # 或者手动连接 (用户名请根据 .env 文件修改)
  ssh shijiashuai@localhost -p 2225
  ```

- **在容器内执行命令**:
  使用 `dev-cli.sh exec` 可以在不进入容器的情况下执行命令。
  ```bash
  # 查看 Samba 服务状态 (示例，需配置后才能正常运行)
  ./dev-cli.sh exec smbstatus
  ```

## 端口映射

| 容器端口      | 主机端口      | 用途        |
|---------------|---------------|-------------|
| 22            | 2225          | SSH 远程管理|
| 139           | 139           | Samba (NetBIOS) |
| 445           | 445           | Samba (SMB) |
| 111 (TCP/UDP) | 111 (TCP/UDP) | NFS Portmapper |
| 2049 (TCP/UDP)| 2049 (TCP/UDP)| NFS Mountd  |

## 卷挂载

- `./share:/export/share`: 将本地的 `./share` 目录挂载到容器的 `/export/share`，可作为示例共享点。您需要自行配置 Samba 或 NFS 来共享此目录。
- `/data-lush:/data-lush`: 挂载一个通用的数据卷，可用于存放大型数据集或项目文件。

**注意**: 本环境仅提供服务软件，您需要进入容器后自行配置 Samba (`smb.conf`) 和 NFS (`/etc/exports`) 来启用文件共享。
