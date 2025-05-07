# 容器迁移脚本 (`migrate_containers.sh`)

该脚本用于将 Docker 容器从一台主机（源主机）迁移到另一台主机（目标主机）。迁移过程包括提交正在运行的容器为新的 Docker 镜像，导出这些镜像为 `.tar` 文件，手动传输这些文件，然后在目标主机上加载镜像并运行新的容器。

## 目录

- [先决条件](#先决条件)
- [配置](#配置)
- [使用步骤](#使用步骤)
  - [第 1 部分：在源主机上操作](#第-1-部分在源主机上操作)
  - [第 2 部分：文件传输](#第-2-部分文件传输)
  - [第 3 部分：在目标主机上操作](#第-3-部分在目标主机上操作)
- [重要注意事项](#重要注意事项)

## 先决条件

- **Docker**：源主机和目标主机上都必须安装 Docker，并且 Docker 服务正在运行。
- **SSH 访问**（推荐）：为了方便地在源主机和目标主机之间传输文件，建议源主机具有到目标主机的 SSH 访问权限（或反之）。
- **磁盘空间**：确保源主机上有足够的磁盘空间来保存导出的 Docker 镜像 `.tar` 文件，目标主机上有足够的空间来存储这些文件并运行新的容器。
- **脚本访问**：脚本 (`migrate_containers.sh`) 需要在源主机和目标主机上都可访问并具有执行权限。

## 配置

在运行脚本之前，请打开 `migrate_containers.sh` 文件并检查/修改以下变量以匹配您的环境和需求：

- `DATE_TAG`：用于标记新创建的 Docker 镜像和导出目录的日期标签。默认为 `"20250506"`。您可以取消注释 `DATE_TAG=$(date +%Y%m%d)` 来使用当前日期。
- `BASE_EXPORT_DIR`：导出 Docker 镜像 `.tar` 文件的基础目录。默认为 `"/data-lush/lush-dev/shijiashuai/baks/dockers"`。
- `EXPORT_DIR`：完整的导出路径，通常是 `${BASE_EXPORT_DIR}/${DATE_TAG}`。

- **AlmaLinux 容器/镜像配置**:
  - `SOURCE_ALMA_CONTAINER_ID_OR_NAME`：源主机上要迁移的 AlmaLinux 容器的 ID 或名称。默认为 `"e30b9c0d851f"`。
  - `TARGET_ALMA_IMAGE_REPO`：新创建的 AlmaLinux 镜像的仓库名。默认为 `"shuai/alma-dev"`。
  - `TARGET_ALMA_IMAGE_NAME`：完整的 AlmaLinux 镜像名称，格式为 `${TARGET_ALMA_IMAGE_REPO}:${DATE_TAG}`。
  - `ALMA_TAR_FILENAME`：导出的 AlmaLinux 镜像的 `.tar` 文件名。
  - `TARGET_ALMA_NEW_CONTAINER_NAME`：在目标主机上运行的 AlmaLinux 新容器的名称。默认为 `"shuai-alma-dev-${DATE_TAG}"`。
  - `TARGET_ALMA_SSH_PORT_MAPPING`：目标主机上 AlmaLinux 容器的 SSH 端口映射 (格式 `HostPort:ContainerPort`)。默认为 `"28991:22"`。**请根据目标主机的端口可用性进行调整。**

- **Ubuntu 容器/镜像配置**:
  - `SOURCE_UBUNTU_CONTAINER_ID_OR_NAME`：源主机上要迁移的 Ubuntu 容器的 ID 或名称。默认为 `"3bd3aec3f3dd"`。
  - `TARGET_UBUNTU_IMAGE_REPO`：新创建的 Ubuntu 镜像的仓库名。默认为 `"shuai/ubuntu-dev"`。
  - `TARGET_UBUNTU_IMAGE_NAME`：完整的 Ubuntu 镜像名称，格式为 `${TARGET_UBUNTU_IMAGE_REPO}:${DATE_TAG}`。
  - `UBUNTU_TAR_FILENAME`：导出的 Ubuntu 镜像的 `.tar` 文件名。
  - `TARGET_UBUNTU_NEW_CONTAINER_NAME`：在目标主机上运行的 Ubuntu 新容器的名称。默认为 `"shuai-ubuntu-dev-${DATE_TAG}"`。
  - `TARGET_UBUNTU_SSH_PORT_MAPPING`：目标主机上 Ubuntu 容器的 SSH 端口映射。默认为 `"28992:22"`。**请根据目标主机的端口可用性进行调整。**
  - `TARGET_UBUNTU_NETDATA_PORT_MAPPING`：目标主机上 Ubuntu 容器的 Netdata 端口映射 (如果需要)。默认为 `"28971:28970"`。**请根据目标主机的端口可用性进行调整。**

确保所有路径和名称都正确无误。

## 使用步骤

### 第 1 部分：在源主机上操作

1.  **赋予执行权限**：
    如果脚本还没有执行权限，请在源主机的终端中运行：
    ```bash
    chmod +x scripts/migrate_containers.sh
    ```

2.  **运行脚本的 `source` 部分**：
    ```bash
    ./scripts/migrate_containers.sh source
    ```
    此命令将执行以下操作：
    -   检查 `docker` 命令是否存在。
    -   根据配置的 `SOURCE_..._CONTAINER_ID_OR_NAME` 提交正在运行的容器为新的 Docker 镜像 (例如 `shuai/alma-dev:20250506` 和 `shuai/ubuntu-dev:20250506`)。
    -   在 `BASE_EXPORT_DIR`下创建 `${DATE_TAG}` 子目录 (例如 `/data-lush/lush-dev/shijiashuai/baks/dockers/20250506/`)。
    -   将新创建的镜像导出为 `.tar` 文件并保存到上述创建的目录中。
    -   完成后，脚本会显示下一步（文件传输）的指示和 `scp` 命令示例。

### 第 2 部分：文件传输

1.  **将导出的文件传输到目标主机**：
    脚本在源主机上成功执行后，您需要将包含 `.tar` 文件的整个 `${EXPORT_DIR}` 目录（例如 `/data-lush/lush-dev/shijiashuai/baks/dockers/20250506/`）从源主机复制到目标主机的 `${BASE_EXPORT_DIR}` 目录下（例如 `/data-lush/lush-dev/shijiashuai/baks/dockers/`）。

    脚本会提供一个 `scp` 命令示例，您可以根据实际情况修改并执行。例如，在**源主机**上运行：
    ```bash
    scp -r /data-lush/lush-dev/shijiashuai/baks/dockers/20250506 your_user@target_host_ip_or_name:/data-lush/lush-dev/shijiashuai/baks/dockers/
    ```
    将 `your_user@target_host_ip_or_name` 替换为目标主机的实际用户名和 IP 地址或主机名。

    确保目标主机上的目标目录存在，并且您有权写入。如果目标基础目录 (`BASE_EXPORT_DIR`) 不存在，请先在目标主机上创建它。

### 第 3 部分：在目标主机上操作

1.  **赋予执行权限**（如果尚未操作）：
    如果脚本还没有执行权限，请在目标主机的终端中运行：
    ```bash
    chmod +x scripts/migrate_containers.sh
    ```

2.  **运行脚本的 `target` 部分**：
    在目标主机上，导航到脚本所在的目录，然后运行：
    ```bash
    ./scripts/migrate_containers.sh target
    ```
    此命令将执行以下操作：
    -   检查 `docker` 命令是否存在。
    -   检查预期的 `.tar` 文件是否存在于 `${EXPORT_DIR}` 目录中。
    -   从 `.tar` 文件加载 Docker 镜像到本地 Docker 环境中。
    -   尝试根据脚本中配置的 `TARGET_..._NEW_CONTAINER_NAME` 和端口映射 (`TARGET_..._PORT_MAPPING`) 从加载的镜像运行新的容器。
        -   新容器将以分离模式 (`-d`) 启动。
        -   新容器将配置为 `--restart unless-stopped`。
        -   脚本会输出用于启动新容器的 `docker run` 命令的相关信息。

3.  **验证容器状态**：
    脚本执行完毕后，在目标主机上检查新容器的状态：
    ```bash
    docker ps -a | grep "${DATE_TAG}" 
    # 或者更具体地：
    docker ps -a | grep "${TARGET_ALMA_NEW_CONTAINER_NAME}"
    docker ps -a | grep "${TARGET_UBUNTU_NEW_CONTAINER_NAME}"
    ```
    使用 `docker logs <container_name_or_id>` 查看容器日志，确保它们按预期启动。

4.  **测试连接**：
    尝试通过为新容器配置的新端口（例如，SSH 端口 `28991` 和 `28992`）连接到服务。

5.  **防火墙配置**（如果需要）：
    如果目标主机上有防火墙（如 `ufw`, `firewalld`），请确保为新容器映射的端口（例如 `28991/tcp`, `28992/tcp`, `28971/tcp`）已打开，以允许外部访问。

## 重要注意事项

- **数据卷 (Volumes)**：此脚本通过 `docker commit` 创建镜像。默认情况下，`docker commit` **不包括**定义为数据卷的内容。如果您的原始容器使用了数据卷来持久化数据，并且您需要迁移这些数据，则需要单独处理这些数据卷的备份和恢复。这通常涉及到在源主机上备份卷数据，将其传输到目标主机，然后在目标主机上创建新卷并将数据恢复进去，最后在运行新容器时挂载这些卷。
- **环境变量和特定配置**：`docker commit` 会保留容器文件系统中的更改以及镜像的 CMD 和 ENTRYPOINT。但是，原始 `docker run` 命令中通过 `--env` 设置的环境变量或通过其他选项（如 `--device`, `--cap-add` 等）进行的特定运行时配置，不会自动包含在提交的镜像中或由脚本重新应用。您需要在脚本的 `run_on_target_host` 函数中的 `docker run` 命令部分手动添加这些必要的选项。
- **网络配置**：脚本为新容器配置了端口映射。如果原始容器有更复杂的网络配置（例如，连接到特定的 Docker 网络），您可能需要在目标主机上手动创建这些网络，并在 `docker run` 命令中添加 `--network` 选项。
- **资源限制**：原始容器的资源限制（如 CPU、内存）也不会通过 `docker commit` 保留。如果需要，请在目标主机的 `docker run` 命令中添加相应的选项（例如 `--cpus`, `--memory`）。
- **错误处理**：脚本包含基本的错误检查（例如，命令是否存在，文件是否存在）。如果发生错误，脚本将打印错误消息并退出。请仔细阅读输出以了解问题所在。
- **测试**：强烈建议首先在非生产环境中测试此脚本和迁移过程，以确保其按预期工作并满足您的所有要求。
- **安全性**：`docker commit` 会将容器当前状态（包括可能存在的敏感信息）保存到新镜像中。请确保在提交之前，容器处于一个安全和干净的状态。

通过仔细配置和执行这些步骤，您应该能够成功地将指定的 Docker 容器从源主机迁移到目标主机。 