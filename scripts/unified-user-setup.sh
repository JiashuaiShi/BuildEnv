#!/bin/bash
# 确保脚本在任何命令失败时立即退出
set -e

#
# 统一用户设置脚本 (Unified User Setup Script)
#
# 功能:
#   为基于 RHEL (如 AlmaLinux, CentOS) 和 Debian (如 Ubuntu) 的系统
#   创建一个具有 sudo 免密权限的非 root 用户。
#   本脚本设计为在 Dockerfile 构建过程中被调用。
#

# --- 脚本参数 ---
# 检查并获取所有必需的参数，如果缺少任何一个，则打印用法并退出。
DEV_USER=${1:?"用法: $0 <用户名> <密码> <用户ID> <用户组> <用户组ID>"}
DEV_PASSWORD=${2:?"用法: $0 <用户名> <密码> <用户ID> <用户组> <用户组ID>"}
USER_UID=${3:?"用法: $0 <用户名> <密码> <用户ID> <用户组> <用户组ID>"}
DEV_GROUP=${4:?"用法: $0 <用户名> <密码> <用户ID> <用户组> <用户组ID>"}
GROUP_GID=${5:?"用法: $0 <用户名> <密码> <用户ID> <用户组> <用户组ID>"}

echo "正在为用户 '${DEV_USER}' 执行统一用户设置..."

# --- 操作系统检测 ---
# 通过检查特定的系统文件来判断当前是 RHEL 系列还是 Debian 系列的系统。
if [ -f /etc/redhat-release ]; then
    OS_FAMILY="rhel"
    SUDO_GROUP="wheel" # 在 RHEL 系列中，拥有 sudo 权限的用户组通常是 'wheel'
    # 确保 'chpasswd' 命令可用，如果不存在则安装 shadow-utils
    if ! command -v chpasswd &> /dev/null; then
        dnf -y install shadow-utils
    fi
elif [ -f /etc/debian_version ]; then
    OS_FAMILY="debian"
    SUDO_GROUP="sudo" # 在 Debian 系列中，拥有 sudo 权限的用户组通常是 'sudo'
    # 确保 'chpasswd' 命令可用，如果不存在则安装 passwd
    if ! command -v chpasswd &> /dev/null; then
        apt-get update && apt-get install -y passwd
    fi
else
    echo "错误: 不支持的操作系统。" >&2
    exit 1
fi

echo "检测到操作系统系列: ${OS_FAMILY}, sudo 用户组: ${SUDO_GROUP}"

# --- 创建用户和用户组 ---
echo "正在创建用户组 '${DEV_GROUP}' (GID: ${GROUP_GID})..."
# 使用 groupadd 创建用户组。如果组已存在，则忽略错误并继续。
groupadd -g "${GROUP_GID}" "${DEV_GROUP}" || echo "用户组 '${DEV_GROUP}' 已存在，跳过创建。"

echo "正在创建用户 '${DEV_USER}' (UID: ${USER_UID})..."
# 使用 useradd 创建用户，并指定其 shell, UID 和 GID。如果用户已存在，则忽略错误。
useradd -m -s /bin/zsh -u "${USER_UID}" -g "${GROUP_GID}" "${DEV_USER}" || echo "用户 '${DEV_USER}' 已存在，跳过创建。"

# --- 设置密码 ---
echo "正在为用户 '${DEV_USER}' 设置密码..."
# 使用 chpasswd 命令从标准输入中读取 "用户名:密码" 并设置密码。
echo "${DEV_USER}:${DEV_PASSWORD}" | chpasswd

# --- 配置 Sudo 权限 ---
echo "正在为用户 '${DEV_USER}' 添加到 '${SUDO_GROUP}' 用户组以获取 sudo 权限..."
usermod -aG "${SUDO_GROUP}" "${DEV_USER}"

# 为 sudo 用户组配置免密 sudo 权限
# 创建一个新的 sudoers 配置文件，而不是直接修改 /etc/sudoers，这是更安全的做法。
SUDOERS_FILE="/etc/sudoers.d/90-nopasswd-${SUDO_GROUP}"
echo "正在配置免密 sudo..."
echo "%${SUDO_GROUP} ALL=(ALL) NOPASSWD: ALL" > "${SUDOERS_FILE}"
# 设置正确的权限，防止未授权的修改
chmod 440 "${SUDOERS_FILE}"

echo "用户 '${DEV_USER}' 创建并配置成功。"
