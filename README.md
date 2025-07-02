# Devenv - 标准化多场景开发环境集合

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

本项目是一个为中文开发者深度优化的标准化、多场景 Docker 开发平台。它旨在为高性能计算 (HPC)、Web 开发和网络附加存储 (NAS) 等不同场景，提供一套安全、可复现且易于管理的容器化开发环境。

## 设计哲学

- **中文优先**: 所有脚本、配置文件和文档均提供详尽的中文注释，旨在消除语言障碍，为中文开发者提供最友好的使用和二次开发体验。
- **标准化与一致性**: 无论您在哪个开发场景下工作，都能获得统一的脚本命令 (`build.sh`, `start.sh`, `dev-cli.sh`) 和一致的操作逻辑，极大降低学习成本。
- **安全为本**: 我们坚决不在代码中硬编码任何敏感信息。所有密码均通过 `.env` 文件进行配置，并通过安全的构建参数传递，确保您的凭证安全。
- **分层构建**: 所有环境均采用 `base` -> `dev` 的分层镜像结构。`base` 镜像提供纯净的操作系统、标准用户和核心服务；`dev` 镜像在此之上叠加具体的开发工具链，使得镜像结构清晰、易于维护和扩展。

## 功能模块概览

```
devenv/
├── dockerfiles/              # 所有 Dockerfile 按场景分类存放
│   ├── ai/                   # AI 开发环境
│   ├── examples/             # 示例环境
│   ├── hpc/                  # 高性能计算环境
│   ├── nas/                  # NAS 服务环境
│   └── web/                  # Web 开发环境
├── scripts/                  # 统一的控制脚本
│   ├── build.sh              # 构建环境
│   ├── start.sh              # 启动环境
│   └── dev-cli.sh            # 与环境交互
└── configs/                  # 全局配置文件
    └── base-config.yaml
```

## 环境依赖

本项目在 Linux, macOS, 或 Windows (通过 WSL 2) 环境下运行。请确保已安装以下工具：

1.  **Docker 和 Docker Compose**: 用于构建和管理容器。
2.  **yq**: 一个轻量级的命令行 YAML 处理器，用于脚本中解析配置文件。请[点击此处](https://github.com/mikefarah/yq/#install)查看其安装方式。
3.  **(Windows 用户)**: 强烈建议安装并使用 **[WSL 2 (Windows Subsystem for Linux)](https://learn.microsoft.com/zh-cn/windows/wsl/install)**。所有脚本都为 Linux 环境设计，在 WSL 2 中可以无缝运行。

## 快速开始

仅需 4 步，即可启动您的专属开发环境：

1.  **进入环境目录**: 
    选择一个你需要的场景，例如 `web` 开发环境。
    ```bash
    cd dockerfiles/web
    ```

2.  **配置环境变量**: 
    从模板复制 `.env` 文件，并根据需要修改其中的配置（例如密码）。
    ```bash
    cp .env.example .env
    ```

3.  **配置环境类型**:
    编辑项目根目录的 `environment.conf` 文件，设置正确的环境类型（如 `ENV_TYPE=web`）

4.  **构建并启动环境**: 
    执行构建脚本，它会自动完成所有镜像的构建和容器的启动。
    ```bash
    ./build.sh
    ```

5.  **开始使用**: 
    构建成功后，你可以通过 `dev-cli.sh` 与你的开发环境交互。
    ```bash
    # 进入容器的 shell
    ./dev-cli.sh ssh

    # 查看实时日志
    ./dev-cli.sh logs

    # 停止环境
    ./dev-cli.sh stop
    ```

## 项目状态

本项目的所有核心功能均已开发完成，并经过了全面的中文本地化和标准化重构。我们欢迎社区开发者进行使用、反馈，并参与到未来的改进中。

## 贡献

如果您有任何建议或发现任何问题，请随时提交 Issue 或 Pull Request。我们非常欢迎您的贡献！
