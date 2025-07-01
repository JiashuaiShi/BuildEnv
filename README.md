# Devenv - 统一开发环境集合

本项目是一个标准化的、多环境的 Docker 开发平台，旨在为不同的开发场景提供一套可复现、安全且易于管理的容器化环境。项目涵盖了高性能计算（HPC）、Web 开发和网络附加存储（NAS）三大核心方向。

## 核心特性

- **分层架构**: 所有环境均采用 `base` -> `dev` 的分层镜像结构。`base` 镜像负责提供纯净的操作系统、标准用户和 SSH 服务；`dev` 镜像在其之上安装具体的开发工具链。
- **标准化管理**: 每个开发环境都配备了一套统一的管理脚本 (`build.sh`, `start.sh`, `dev-cli.sh`)，提供了一致的操作体验。
- **安全优先**: 彻底移除硬编码密码。所有用户密码均通过各个环境目录下的 `.env` 文件进行配置，并通过构建参数安全地传递。
- **跨平台兼容**: 通过统一的用户设置脚本 (`unified-user-setup.sh`)，实现了在 AlmaLinux (RHEL 系列) 和 Ubuntu (Debian 系列) 上的一致性用户管理。
- **文档清晰**: 每个环境都拥有独立的 `README.md`，详细说明其特性和使用方法。

## 最终目录结构

```
devenv/
├── scripts/                  # 统一的用户设置脚本
│   └── unified-user-setup.sh
├── 02-dev-hpc/               # 高性能计算开发环境
│   ├── 02-alma/
│   │   ├── base/             # AlmaLinux 基础镜像
│   │   └── alma-dev/         # AlmaLinux C++/Java 开发环境
│   └── 03-ubuntu/
│       ├── base/             # Ubuntu 基础镜像
│       └── dev/              # Ubuntu C++/Java 开发环境
├── 03-dev-web/               # Web 开发环境
│   ├── base/                 # Ubuntu + Node.js + Python 基础镜像
│   └── dev/                  # Web 前端工具开发环境
└── 04-dev-nas/               # NAS 服务环境
    ├── base/                 # AlmaLinux + Samba + NFS 基础镜像
    └── dev/                  # NAS 管理环境
```

## 开发路线图 (已全部完成)

-   [x] **阶段一: 基础镜像标准化**
    -   [x] `alma-base`: 完成基于 AlmaLinux 9 的安全基础镜像。
    -   [x] `ubuntu-base`: 完成基于 Ubuntu 24.04 的安全基础镜像。
    -   [x] **成果**: 两个基础镜像都包含 SSH、Supervisor 和通过统一脚本实现的安全用户管理机制。

-   [x] **阶段二: HPC 开发环境构建**
    -   [x] `alma-dev`: 基于 `alma-base` 构建了包含 C++ (GCC, Clang, CMake) 和 Java (OpenJDK, Maven) 工具链的开发环境。
    -   [x] `ubuntu-dev`: 基于 `ubuntu-base` 构建了功能对等的 HPC 开发环境。

-   [x] **阶段三: Web 开发环境构建**
    -   [x] `web-base`: 基于 Ubuntu 创建了包含 Node.js 和 Python 的基础镜像。
    -   [x] `web-dev`: 安装了通用的前端开发工具 (`create-react-app`, `@vue/cli`)。

-   [x] **阶段四: NAS 服务环境构建**
    -   [x] `nas-base`: 基于 AlmaLinux 创建了包含 Samba 和 NFS 工具的基础镜像。
    -   [x] `nas-dev`: 提供了可用于 NAS 管理和配置的终端环境。

-   [x] **阶段五: 整体优化与文档完善**
    -   [x] **统一脚本**: 创建 `unified-user-setup.sh`，统一了所有环境的用户创建逻辑。
    -   [x] **标准化管理**: 为所有 `dev` 环境配备了 `build.sh`, `start.sh`, `dev-cli.sh` 脚本。
    -   [x] **文档**: 为每个模块创建了独立的 `README.md`，并更新了此主文档。

## 如何开始

1.  **选择环境**: 进入您想使用的开发环境的 `dev` 目录（例如 `02-dev-hpc/02-alma/alma-dev`）。
2.  **配置密码**: 打开该目录下的 `.env` 文件，修改 `DEV_PASSWORD` 的值。
3.  **构建镜像**:
    ```bash
    ./build.sh
    ```
4.  **启动容器**:
    ```bash
    ./start.sh
    ```
5.  **开始使用**: 参考该目录下的 `README.md` 和 `dev-cli.sh` 脚本进行操作（如 `ssh`, `exec` 等）。

