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
├── scripts/                  # 统一的用户设置脚本 (已汉化)
│   └── unified-user-setup.sh
├── 02-dev-hpc/               # 高性能计算开发环境
│   ├── 02-alma/              # AlmaLinux (C++/Java)
│   └── 03-ubuntu/            # Ubuntu (C++/Java)
├── 03-dev-web/               # Web 全栈开发环境
│   └── dev/                  # Ubuntu (Node.js/Python)
└── 04-dev-nas/               # NAS 服务与管理环境
    └── dev/                  # AlmaLinux (Samba/NFS)
```

## 快速开始

仅需 4 步，即可启动您的专属开发环境：

1.  **进入环境目录**: 
    选择您需要的环境，并进入其 `dev` 目录。例如，要使用 AlmaLinux 的 HPC 环境：
    ```bash
    cd 02-dev-hpc/02-alma/alma-dev
    ```

2.  **配置您的密码**: 
    复制 `.env.example` 文件为 `.env`，并修改 `DEV_PASSWORD` 的值为您的安全密码。
    ```bash
    cp .env.example .env
    # 使用编辑器打开 .env 并修改密码
    ```
    **警告：请勿在生产环境中使用默认密码！**

3.  **构建镜像**: 
    执行构建脚本。此过程会自动处理基础镜像和开发镜像的构建。
    ```bash
    ./build.sh
    ```

4.  **启动并使用**: 
    启动容器，然后您就可以通过 SSH 登录或执行其他命令了。
    ```bash
    # 启动容器 (后台运行)
    ./start.sh

    # 通过 SSH 登录容器
    ./start.sh ssh

    # 在容器内执行命令 (例如: 查看 gcc 版本)
    ./start.sh exec gcc --version
    ```

## 项目状态

本项目的所有核心功能均已开发完成，并经过了全面的中文本地化和标准化重构。我们欢迎社区开发者进行使用、反馈，并参与到未来的改进中。

## 贡献

如果您有任何建议或发现任何问题，请随时提交 Issue 或 Pull Request。我们非常欢迎您的贡献！
