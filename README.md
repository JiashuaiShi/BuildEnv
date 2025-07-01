# Devenv - 统一开发环境集合

本项目旨在为不同的开发场景提供一套标准化、可复现、易于管理的 Docker 化开发环境。项目涵盖了高性能计算（HPC）、Web 开发和 NAS 服务三大方向。

## 项目目标

- **标准化与一致性**: 为不同项目和团队提供统一的基础环境，减少环境配置差异带来的问题。
- **模块化与可扩展**: 通过分层 Docker 镜像，实现基础系统、开发工具和项目代码的解耦，易于扩展和维护。
- **安全与高效**: 移除硬编码密码，通过构建参数和 `.env` 文件管理敏感信息，优化构建流程，提升效率。
- **文档清晰**: 提供清晰的文档，方便新成员快速上手。

## 目录结构

```
devenv/
├── 01-docs/                # 文档目录 (规划中)
├── 02-dev-hpc/             # 高性能计算开发环境
│   ├── 01-common-scripts/  # 通用脚本
│   ├── 02-alma/            # AlmaLinux 系列环境
│   │   ├── base/           # AlmaLinux 基础镜像 (SSH, Supervisor, 用户)
│   │   └── alma-dev/       # AlmaLinux C++/Java 开发环境
│   └── 03-ubuntu/          # Ubuntu 系列环境 (规划中)
├── 03-dev-web/             # Web 开发环境 (规划中)
└── 04-dev-nas/             # NAS 服务部署 (规划中)
```

## 开发路线图 (Roadmap)

-   [x] **阶段一: 基础镜像标准化**
    -   [x] `alma-base`: 完成最小化、安全的 AlmaLinux 基础镜像，包含 SSH、Supervisor 和安全的用户管理机制。
    -   [ ] `ubuntu-base`: 完成最小化、安全的 Ubuntu 基础镜像。
-   [x] **阶段二: HPC 开发环境构建**
    -   [x] `alma-dev`: 基于 `alma-base` 构建包含 C++ (GCC, Clang, CMake) 和 Java (OpenJDK, Maven) 工具链的开发环境。
    -   [ ] `ubuntu-dev`: 基于 `ubuntu-base` 构建 HPC 开发环境。
-   [ ] **阶段三: Web 开发环境构建**
    -   规划并实施包含 Nginx, Node.js, Python, Go 等常用工具的 Web 开发环境。
-   [ ] **阶段四: NAS 服务定义**
    -   提供常用 NAS 服务的 Docker Compose 模板，如 Gitea, Jellyfin, Portainer 等。
-   [ ] **阶段五: 整体优化与文档完善**
    -   完善所有环境的文档，并集成 VS Code Devcontainer 支持。

## 通用约定

- **镜像命名**: 基础镜像统一命名为 `os-base:latest` (如 `alma-base:latest`)，开发环境镜像命名为 `os-dev:latest` (如 `alma-dev:latest`)。
- **密码管理**: 所有镜像的初始用户密码均通过构建参数 `DEV_PASSWORD` 在构建时传入，避免硬编码。

## 如何开始

请参考具体开发环境目录下的 `README.md` 文件以获取详细的构建和使用说明。例如，要构建 AlmaLinux 的 C++/Java 开发环境，请进入 `02-dev-hpc/02-alma/alma-dev` 目录并遵循其文档指示。
