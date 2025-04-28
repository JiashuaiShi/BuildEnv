# 解决 Ubuntu 24.04 (Noble) Docker 构建中 APT GPG 密钥错误 (NO_PUBKEY 871920D1991BC93C)

## 问题描述

在基于 Ubuntu 24.04 (Noble Numbat) 的 Docker 环境中，使用第三方镜像源（如阿里云 `mirrors.aliyun.com`）替换官方源时，执行 `apt-get update` 可能会遇到 GPG 签名验证错误，即使已经按照推荐方式配置了镜像源的 GPG 密钥。具体的错误信息通常是：

```
W: GPG error: http://mirrors.aliyun.com/ubuntu noble InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 871920D1991BC93C
E: The repository 'http://mirrors.aliyun.com/ubuntu noble InRelease' is not signed.
... (类似错误针对 noble-security, noble-updates, noble-backports) ...
The command '/bin/sh -c apt-get update' returned a non-zero code: 100
```

错误指向缺少公钥 `871920D1991BC93C`，这是 Ubuntu 官方用于签署其仓库的密钥之一。

## 根本原因分析

1.  **APT 验证机制变化**: Ubuntu 24.04 遵循了 Debian 的策略，弃用了 `apt-key` 工具和全局信任的 `/etc/apt/trusted.gpg.d/` 目录。推荐的方式是将密钥存储在 `/usr/share/keyrings/` 或 `/etc/apt/keyrings/` 目录下，并在源列表文件 (`/etc/apt/sources.list` 或 `.list` 文件) 中使用 `[signed-by=/path/to/key.gpg]` 选项明确指定用于验证该源的密钥。
2.  **镜像源验证逻辑**: 即使你配置了镜像源（如阿里云），并下载了**镜像源本身**的 GPG 密钥，`apt-get update` 在处理这些镜像仓库时，似乎仍然**需要 Ubuntu 官方的签名密钥** (`871920D1991BC93C`) 来完成验证链或某些基础包的验证。仅仅提供镜像源自身的密钥是不够的。
3.  **配置不匹配**: 如果 `/etc/apt/sources.list` 文件（或 `.list` 文件）配置了镜像源，但没有通过 `[signed-by=...]` 明确指定使用我们手动下载并放置在 keyring 目录下的**官方密钥** (`871920D1991BC93C`)，APT 就无法完成验证，因为它不知道应该用这个特定的密钥来验证这个镜像源。

## 解决思路与方法

核心思路是：**让 APT 知道应该使用哪个 GPG 密钥来验证特定的仓库**，并且这个密钥必须是 APT 认为验证该仓库所必需的那个（在这个案例中是 Ubuntu 官方密钥 `871920D1991BC93C`）。

具体步骤如下：

1.  **安装必要工具**: 确保 Dockerfile 中安装了 `curl`, `gnupg`, `ca-certificates`。
2.  **获取缺失的 Ubuntu 官方密钥**: 从可靠的密钥服务器（如 `keyserver.ubuntu.com`）下载公钥 `871920D1991BC93C`。
3.  **存储密钥**: 使用 `gpg --dearmor` 将下载的密钥转换为二进制格式，并存储到推荐的 keyring 目录，例如 `/usr/share/keyrings/ubuntu-archive-871920D1991BC93C.gpg`。确保文件权限正确（通常是 `644`）。
4.  **配置 APT 源列表**:
    *   创建或修改 `/etc/apt/sources.list` 文件（或其他 `.list` 文件），使其指向你的镜像源（例如阿里云）。
    *   在每一行 `deb` 指令中，**必须**使用 `[signed-by=/usr/share/keyrings/ubuntu-archive-871920D1991BC93C.gpg]` 选项，明确告知 APT 使用我们下载的那个**官方密钥**来验证这个**镜像源**。
5.  **(可选但推荐) 清理冲突**: 如果存在官方源的配置文件（如 `/etc/apt/sources.list.d/ubuntu.sources`），将其重命名或删除，避免潜在的源冲突。
6.  **更新 APT 缓存**: 执行 `apt-get update`。此时 APT 应该能够成功验证镜像源的签名。

## Dockerfile 示例代码片段

```dockerfile
# --- Configure APT sources for Aliyun mirror using the required Ubuntu Key ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg wget \
    && rm -rf /var/lib/apt/lists/* \
    # Define variables within the RUN command's shell environment
    && ALIYUN_MIRROR_URL="http://mirrors.aliyun.com/ubuntu/" \
    && MISSING_KEY_ID="871920D1991BC93C" \
    # Choose a descriptive path for the key
    && KEY_FILE_PATH="/usr/share/keyrings/ubuntu-archive-${MISSING_KEY_ID}.gpg" \
    \
    # 1. (可选) 禁用官方源配置文件，避免冲突
    && if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
           mv /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.disabled; \
           echo "Disabled /etc/apt/sources.list.d/ubuntu.sources"; \
       else \
           echo "/etc/apt/sources.list.d/ubuntu.sources not found, skipping disable."; \
       fi \
    \
    # 2. 创建 /etc/apt/sources.list 指向阿里云, 并指定用下载的 Ubuntu 密钥验证
    #    注意 [signed-by=${KEY_FILE_PATH}]
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble main restricted universe multiverse" > /etc/apt/sources.list \
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb [signed-by=${KEY_FILE_PATH}] ${ALIYUN_MIRROR_URL} noble-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    \
    # 3. 下载缺失的 Ubuntu GPG 密钥并保存到指定路径
    && echo "Downloading GPG key ${MISSING_KEY_ID} to ${KEY_FILE_PATH}..." \
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${MISSING_KEY_ID}" | gpg --dearmor -o "${KEY_FILE_PATH}" \
    && chmod 644 "${KEY_FILE_PATH}" \
    # Verify key download
    && if [ ! -s "${KEY_FILE_PATH}" ]; then echo "Error: Failed to download GPG key ${MISSING_KEY_ID}."; exit 1; fi \
    && echo "GPG key downloaded and permissions set." \
    \
    # 4. Clean up before the next step's update
    && apt-get clean

# --- Update APT cache using the new sources and key ---
RUN apt-get update

# --- Install packages --- 
# Now you can install packages from the mirror
RUN apt-get install -y --no-install-recommends your-package
```

通过这种方式配置，即使使用的是镜像源，APT也能利用正确的官方密钥完成签名验证，从而解决 `NO_PUBKEY` 错误。 