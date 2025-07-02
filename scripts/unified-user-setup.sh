#!/bin/bash

# --- 脚本健壮性设置 ---
# set -e: 如果任何命令以非零状态退出，则立即退出脚本。
# set -u: 将任何未设置的变量视为错误，防止因变量为空导致意外行为。
# set -o pipefail: 如果管道中的任何命令失败，则整个管道的返回码为该失败命令的返回码。
set -euo pipefail

# --- ANSI 颜色代码定义 ---
# 用于彩色日志输出，增强可读性。
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # No Color

# --- 日志函数封装 ---
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"
}
log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_NC} $1"
}
log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $1"
}

# --- 脚本参数校验 ---
if [ "$#" -ne 5 ]; then
    echo "错误: 参数数量不足或过多。" >&2
    echo "用法: $0 <用户名> <密码> <用户ID> <用户组> <用户组ID>" >&2
    exit 1
fi

DEV_USER="$1"
DEV_PASSWORD="$2"
USER_UID="$3"
DEV_GROUP="$4"
GROUP_GID="$5"

log_info "开始为用户 '${DEV_USER}' 执行统一设置..."

# --- 操作系统检测与依赖安装 ---
SUDO_GROUP=""
if [ -f /etc/redhat-release ]; then
    log_info "检测到 RHEL/AlmaLinux/CentOS 系列操作系统。"
    SUDO_GROUP="wheel"
    if ! command -v chpasswd &> /dev/null; then
        log_info "'chpasswd' 命令不存在，正在安装 'shadow-utils'..."
        dnf -y install shadow-utils
    fi
elif [ -f /etc/debian_version ]; then
    log_info "检测到 Debian/Ubuntu 系列操作系统。"
    SUDO_GROUP="sudo"
    if ! command -v chpasswd &> /dev/null; then
        log_info "'chpasswd' 命令不存在，正在安装 'passwd'..."
        apt-get update && apt-get install -y passwd
    fi
else
    echo "错误: 不支持的操作系统。" >&2
    exit 1
fi

# --- 创建用户组 (幂等操作) ---
log_info "检查用户组 '${DEV_GROUP}' (GID: ${GROUP_GID})..."
if getent group "${DEV_GROUP}" >/dev/null; then
    log_warn "用户组 '${DEV_GROUP}' 已存在，跳过创建。"
elif getent group "${GROUP_GID}" >/dev/null; then
    EXISTING_GROUP=$(getent group "${GROUP_GID}" | cut -d: -f1)
    log_warn "GID '${GROUP_GID}' 已被用户组 '${EXISTING_GROUP}' 占用，跳过创建。"
else
    log_info "正在创建用户组 '${DEV_GROUP}' (GID: ${GROUP_GID})..."
    groupadd --gid "${GROUP_GID}" "${DEV_GROUP}"
    log_success "用户组 '${DEV_GROUP}' 创建成功。"
fi

# --- 创建用户 (幂等操作) ---
log_info "检查用户 '${DEV_USER}' (UID: ${USER_UID})..."
if id -u "${DEV_USER}" >/dev/null 2>&1; then
    log_warn "用户 '${DEV_USER}' 已存在，跳过创建。"
elif getent passwd "${USER_UID}" >/dev/null; then
    EXISTING_USER=$(getent passwd "${USER_UID}" | cut -d: -f1)
    log_warn "UID '${USER_UID}' 已被用户 '${EXISTING_USER}' 占用，跳过创建。"
else
    log_info "正在创建用户 '${DEV_USER}' (UID: ${USER_UID})..."
    useradd --shell /bin/zsh --uid "${USER_UID}" --gid "${GROUP_GID}" --create-home "${DEV_USER}"
    log_success "用户 '${DEV_USER}' 创建成功。"
fi

# --- 设置密码 ---
log_info "正在为用户 '${DEV_USER}' 设置密码..."
echo "${DEV_USER}:${DEV_PASSWORD}" | chpasswd
log_success "密码设置成功。"

# --- 配置 Sudo 权限 ---
log_info "正在将用户 '${DEV_USER}' 添加到 '${SUDO_GROUP}' 用户组..."
usermod -aG "${SUDO_GROUP}" "${DEV_USER}"

# 为 sudo 用户组配置免密 sudo 权限 (这是比直接修改 /etc/sudoers 更安全的做法)
SUDOERS_FILE="/etc/sudoers.d/90-nopasswd-${SUDO_GROUP}"
log_info "正在为 '${SUDO_GROUP}' 组配置免密 sudo 权限..."
echo "# 由 unified-user-setup.sh 自动生成" > "${SUDOERS_FILE}"
echo "%${SUDO_GROUP} ALL=(ALL) NOPASSWD: ALL" >> "${SUDOERS_FILE}"
chmod 440 "${SUDOERS_FILE}"
log_success "免密 sudo 配置完成。"

log_success "用户 '${DEV_USER}' 的所有配置已成功完成！"
