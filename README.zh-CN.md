# “环境即代码”：标准化的 Docker 开发框架

本项目提供了一个标准化的三层框架，用于创建和管理基于 Docker 的开发环境。它通过采用“环境即代码”的理念，旨在提升一致性、可重用性和可维护性。

## 核心概念

该框架构建于一个三层架构之上：

1.  **基础层 (`env-dev/base/`)**: 包含最小化的操作系统基础镜像（如 Ubuntu, AlmaLinux），并带有通用配置，如用户设置和常用工具。
2.  **变体层 (`env-dev/variant/`)**: 扩展基础镜像，为其添加特定的服务管理系统（如 `systemd`, `supervisor`）。该层定义了服务*如何*运行。
3.  **应用层 (`env-dev/app/`)**: 扩展变体镜像，为其添加特定语言的工具和依赖（如 C++/Python 工具链, NodeJS 等）。这是最终面向用户的开发环境。

## 如何使用

### 构建环境

一个中心化的构建脚本会处理整个依赖链（`基础层` -> `变体层` -> `应用层`）的构建。

要构建 `dev-cpp-python` 环境：
```bash
./build-logic/scripts/build.sh dev-cpp-python
```

### 管理环境

每个应用环境都有一个轻量级的包装脚本（`2-dev-cli.sh`），它将命令委托给一个中心化的管理脚本。

要启动 `dev-cpp-python` 容器：
```bash
./env-dev/app/dev-cpp-python/2-dev-cli.sh start
```

要进入容器的 shell 环境：
```bash
./env-dev/app/dev-cpp-python/2-dev-cli.sh exec bash
```

可用命令：`start`, `stop`, `restart`, `rm`, `logs`, `exec`, `status`, `rmi`, `help`。

## 目录结构

```
.
├── build-logic/
│   └── scripts/
│       ├── build.sh          # 中心化构建脚本
│       └── manage-env.sh     # 中心化管理脚本
├── env-dev/
│   ├── app/
│   │   └── dev-cpp-python/   # 示例应用环境
│   │       ├── Dockerfile
│   │       ├── .env
│   │       ├── docker-compose.yaml
│   │       └── 2-dev-cli.sh
│   ├── base/
│   │   └── ubuntu/           # 示例基础层
│   └── variant/
│       ├── ubuntu-supervisor/ # 示例变体层
│       └── ubuntu-systemd/
├── README.md
└── ROADMAP.md
```
