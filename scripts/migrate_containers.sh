#!/bin/bash
set -e # 如果命令以非零状态退出，则立即退出。

# --- 脚本概述 ---
# 功能: 此脚本用于将 Docker 容器从一台机器 (源机器) 迁移到另一台机器 (目标机器)。
#       它通过提交正在运行的容器为新镜像，导出镜像为 .tar 文件，
#       然后在目标机器上加载这些镜像并运行新容器来完成迁移。
#
# 执行流程:
# 1. 在 源机器 (Source Host) 上运行:
#    - `./migrate_containers.sh source`
#    - 此步骤会:
#      a. 将指定的正在运行的容器提交 (commit) 为新的 Docker 镜像。
#      b. 将这些新镜像导出 (save) 为 .tar 归档文件。
#      c. 导出的文件将存放在下面配置的 EXPORT_DIR 目录中。
#
# 2. 手动传输 (Manual Transfer):
#    - 将源机器上 ${EXPORT_DIR} 目录中的 .tar 文件复制到目标机器 (Target Host) 的
#      相同路径 (${EXPORT_DIR})下。
#    - 可以使用 scp, rsync 或其他文件传输工具。
#
# 3. 在 目标机器 (Target Host) 上运行:
#    - `./migrate_containers.sh target`
#    - 此步骤会:
#      a. 从 .tar 文件加载 (load) Docker 镜像。
#      b. 基于加载的镜像运行新的 Docker 容器，并配置端口映射等。
#
# !! 重要提示 !!
# - 在执行任何操作之前，请务必备份重要数据。
# - 请仔细阅读并根据您的实际环境修改下面的 "脚本配置" 部分。
# - 确保源机器和目标机器上都已正确安装并配置了 Docker。
# -----------------------------------------------------------------------------

# --- 脚本配置 - 请根据实际情况修改以下值 ---
# -----------------------------------------------------------------------------

# --- 全局配置 ---
# DATE_TAG: 用于标记导出的镜像和归档文件。
#           可以取消注释下一行以使用当前日期 (YYYYMMDD) 作为标签，
#           或手动设置为一个特定的标签字符串。
# DATE_TAG=$(date +%Y%m%d)
DATE_TAG="20250506"    # 示例: 使用固定日期标签，请按需修改

# BASE_EXPORT_DIR: 导出 .tar 文件的基础目录路径。
#                  此路径应在源机器和目标机器上均可访问 (用于存放和读取 .tar 文件)。
#                  请确保您对此目录具有读写权限。
BASE_EXPORT_DIR="/data-lush/lush-dev/shijiashuai/baks/dockers" # 示例路径，请按需修改

# EXPORT_DIR: 完整的导出路径，基于 BASE_EXPORT_DIR 和 DATE_TAG。
#             此变量由脚本自动生成，通常无需修改。
EXPORT_DIR="${BASE_EXPORT_DIR}/${DATE_TAG}"

# --- 源容器及目标镜像仓库配置 ---
# AlmaLinux
SOURCE_ALMA_CONTAINER_ID_OR_NAME="e30b9c0d851f"   # 源AlmaLinux容器ID或名称
TARGET_ALMA_IMAGE_REPO="shuai/alma-dev"           # AlmaLinux镜像的目标仓库名

# Ubuntu
SOURCE_UBUNTU_CONTAINER_ID_OR_NAME="3bd3aec3f3dd" # 源Ubuntu容器ID或名称
TARGET_UBUNTU_IMAGE_REPO="shuai/ubuntu-dev"         # Ubuntu镜像的目标仓库名

# --- 目标机器新容器配置 ---
# AlmaLinux
TARGET_ALMA_NEW_CONTAINER_NAME="shuai-alma-dev-${DATE_TAG}" # 目标AlmaLinux容器名称
TARGET_ALMA_SSH_PORT_MAPPING="28991:22"                   # AlmaLinux SSH端口映射 (主机:容器)

# Ubuntu
TARGET_UBUNTU_NEW_CONTAINER_NAME="shuai-ubuntu-dev-${DATE_TAG}" # 目标Ubuntu容器名称
TARGET_UBUNTU_SSH_PORT_MAPPING="28992:22"                     # Ubuntu SSH端口映射 (主机:容器)
TARGET_UBUNTU_NETDATA_PORT_MAPPING="28971:28970"               # Ubuntu Netdata端口映射 (主机:容器), 可留空

# -----------------------------------------------------------------------------
# --- 辅助函数 ---
# -----------------------------------------------------------------------------

# info: 打印信息性消息 (英文)。
info() {
    echo "[INFO] $1"
}

# error: 打印错误消息 (英文) 并退出脚本。
error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# ensure_command_exists: 检查指定的命令是否存在，如果不存在则报错退出。
ensure_command_exists() {
    command -v "$1" >/dev/null 2>&1 || error "Required command '$1' is not installed. Please install it and try again."
}

# _commit_and_export_image: 提交正在运行的容器为新镜像，并将新镜像导出为 .tar 文件。
# 参数:
#   $1: os_label (字符串, 用于日志区分, e.g., "Alma" or "Ubuntu")
#   $2: source_container_id (字符串, 源容器ID或名称)
#   $3: image_repo (字符串, 目标镜像仓库名)
#   $4: current_date_tag (字符串, 日期标签)
#   $5: current_export_dir (字符串, 导出目录路径)
_commit_and_export_image() {
    local os_label="$1"
    local source_container_id="$2"
    local image_repo="$3"
    local current_date_tag="$4"
    local current_export_dir="$5"

    local target_image_name="${image_repo}:${current_date_tag}"
    # 将仓库名中的 / 替换为 _，以兼容文件名
    local tar_filename_base
    tar_filename_base=$(echo "${image_repo}" | tr '/' '_')
    local tar_filepath="${current_export_dir}/${tar_filename_base}_${current_date_tag}.tar"

    info "Committing container ${source_container_id} (${os_label}) to image ${target_image_name}..."
    if ! docker ps -q --filter "id=${source_container_id}" --filter "status=running" | grep -q .; then
        error "Container ${source_container_id} (${os_label}) is not running or does not exist."
    fi
    docker commit "${source_container_id}" "${target_image_name}"
    info "Successfully committed image ${target_image_name}"

    info "Exporting image ${target_image_name} to ${tar_filepath}..."
    docker save -o "${tar_filepath}" "${target_image_name}"
    info "Successfully exported image ${target_image_name} to ${tar_filepath}"
}

# _load_and_run_image: 从 .tar 文件加载镜像，并根据提供的参数运行新容器。
# 参数:
#   $1: os_label (字符串, 用于日志区分)
#   $2: image_repo (字符串, 目标镜像仓库名)
#   $3: current_date_tag (字符串, 日期标签)
#   $4: current_export_dir (字符串, 导出目录路径)
#   $5: new_container_name (字符串, 新容器的名称)
#   $6: port_mappings_array (Bash数组的字符串表示, e.g., "(\"2222:22\" \"8080:80\")" )
_load_and_run_image() {
    local os_label="$1"
    local image_repo="$2"
    local current_date_tag="$3"
    local current_export_dir="$4"
    local new_container_name="$5"
    # 将字符串形式的数组转换为实际的 Bash 数组
    eval "local port_mappings_array=${6}"


    local target_image_name="${image_repo}:${current_date_tag}"
    local tar_filename_base
    tar_filename_base=$(echo "${image_repo}" | tr '/' '_')
    local tar_filepath="${current_export_dir}/${tar_filename_base}_${current_date_tag}.tar"

    if [ ! -f "${tar_filepath}" ]; then
        error "${os_label} image tar file not found: ${tar_filepath}"
    fi

    info "Loading image ${target_image_name} from ${tar_filepath}..."
    docker load -i "${tar_filepath}"
    info "Successfully loaded image ${target_image_name}"

    info "Attempting to run new ${os_label} container (${new_container_name}) from image ${target_image_name}..."
    info "It will be named: ${new_container_name}"

    local docker_run_opts=()
    docker_run_opts+=("-d")
    docker_run_opts+=("--name" "${new_container_name}")
    
    for mapping in "${port_mappings_array[@]}"; do
        if [ -n "$mapping" ]; then #确保映射字符串不为空
            docker_run_opts+=("-p" "${mapping}")
            info "Port mapping: ${mapping} (Host:Container)"
        fi
    done
    
    docker_run_opts+=("--restart" "unless-stopped")
    docker_run_opts+=("${target_image_name}")

    info "Command used for original container was preserved by \'docker commit\' and will be used."
    # 使用 eval 来正确处理参数中的空格等，或者直接展开数组
    info "Starting container with command: docker run ${docker_run_opts[*]}"
    docker run "${docker_run_opts[@]}"
        # TODO: 根据原始容器的配置和您的具体需求，在此处添加其他必要的 \'docker run\' 选项。
        #       例如:
        #         -v /host/path:/container/path      # 卷挂载 (将宿主机目录映射到容器内)
        #         --env MY_VARIABLE="some_value"     # 设置环境变量
        #         --add-host=custom.host:1.2.3.4     # 添加自定义 host 到容器的 /etc/hosts
        #         --network <your_custom_network>    # 连接到指定的 Docker 网络
        #         --dns <dns_server_ip>              # 设置 DNS 服务器
        #         --cap-add <CAPABILITY>             # 添加 Linux capabilities (如 SYS_ADMIN)
        #         --security-opt seccomp=unconfined  # 安全选项 (请谨慎使用)
        #         --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 # 配置日志
        #         # (以及其他任何适用于您场景的参数，请参考 'docker run --help' 或原始容器的启动参数)
    info "${os_label} container ${new_container_name} start command issued."
    info "Check status with: docker ps -a | grep ${new_container_name} and docker logs ${new_container_name}"
}


# -----------------------------------------------------------------------------
# --- 脚本逻辑 ---
# -----------------------------------------------------------------------------

# run_on_source_host: 在源机器上执行的函数。
run_on_source_host() {
    info "--- Running on SOURCE host ---"
    ensure_command_exists "docker"

    info "Creating export directory (if it doesn't exist): ${EXPORT_DIR}"
    mkdir -p "${EXPORT_DIR}" # -p: 如果父目录不存在则一并创建，且如果目录已存在也不会报错
    info "Export directory created/confirmed: ${EXPORT_DIR}"

    # 处理 AlmaLinux 容器
    _commit_and_export_image "AlmaLinux" \
        "${SOURCE_ALMA_CONTAINER_ID_OR_NAME}" \
        "${TARGET_ALMA_IMAGE_REPO}" \
        "${DATE_TAG}" \
        "${EXPORT_DIR}"

    # 处理 Ubuntu 容器
    _commit_and_export_image "Ubuntu" \
        "${SOURCE_UBUNTU_CONTAINER_ID_OR_NAME}" \
        "${TARGET_UBUNTU_IMAGE_REPO}" \
        "${DATE_TAG}" \
        "${EXPORT_DIR}"

    info "--- SOURCE host operations complete ---"
    info "Next steps:"
    info "1. Transfer the .tar files from ${EXPORT_DIR} on this source host"
    info "   to the same base path (${BASE_EXPORT_DIR}/ resulting in target dir ${EXPORT_DIR}) on the TARGET host."
    info "   You can use tools like scp or rsync."
    info "   Example using scp (run from this source host, replace 'user@target_host_ip_or_name' as needed):"
    info "   scp -r \"${EXPORT_DIR}\" user@target_host_ip_or_name:${BASE_EXPORT_DIR}/"
    info "   (Ensure '${BASE_EXPORT_DIR}/' exists on target or adjust scp destination. After transfer, ${EXPORT_DIR} should exist on target.)"
    info "2. Then, run the 'target' part of this script on the TARGET host: $0 target"
}

# run_on_target_host: 在目标机器上执行的函数。
run_on_target_host() {
    info "--- Running on TARGET host ---"
    ensure_command_exists "docker"

    if [ ! -d "${EXPORT_DIR}" ]; then
        error "Export directory ${EXPORT_DIR} not found. Ensure files were transferred correctly to this path."
    fi

    # 处理 AlmaLinux 镜像和容器
    local alma_ports_array="(\"${TARGET_ALMA_SSH_PORT_MAPPING}\")"
    _load_and_run_image "AlmaLinux" \
        "${TARGET_ALMA_IMAGE_REPO}" \
        "${DATE_TAG}" \
        "${EXPORT_DIR}" \
        "${TARGET_ALMA_NEW_CONTAINER_NAME}" \
        "${alma_ports_array}"

    # 处理 Ubuntu 镜像和容器
    local ubuntu_ports_array_list=()
    ubuntu_ports_array_list+=("\"${TARGET_UBUNTU_SSH_PORT_MAPPING}\"")
    if [ -n "${TARGET_UBUNTU_NETDATA_PORT_MAPPING}" ]; then
        ubuntu_ports_array_list+=("\"${TARGET_UBUNTU_NETDATA_PORT_MAPPING}\"")
    fi
    local ubuntu_ports_array_str="($(IFS=" "; echo "${ubuntu_ports_array_list[*]}"))" #转换为 "(item1 item2)" 格式

    _load_and_run_image "Ubuntu" \
        "${TARGET_UBUNTU_IMAGE_REPO}" \
        "${DATE_TAG}" \
        "${EXPORT_DIR}" \
        "${TARGET_UBUNTU_NEW_CONTAINER_NAME}" \
        "${ubuntu_ports_array_str}"
        

    info "--- TARGET host operations complete ---"
    info "Verify that the new containers are running correctly (use 'docker ps -a') and are accessible via their new ports."
    info "If a container failed to start, check 'docker logs <container_name>' for details."
    info "Remember to configure any necessary firewalls on the target host for the new ports."
}

# -----------------------------------------------------------------------------
# --- 主执行逻辑 ---
# -----------------------------------------------------------------------------
# 此脚本需要一个参数来指定是在源机器 ('source') 还是目标机器 ('target') 上运行。
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source|target>"
    echo ""
    echo "  source: Run on the SOURCE machine."
    echo "          This commits specified running containers and exports them to TAR files in"
    echo "          ${EXPORT_DIR}"
    echo ""
    echo "  target: Run on the TARGET machine."
    echo "          This loads images from TAR files (expected in ${EXPORT_DIR})"
    echo "          and runs new containers from them."
    echo ""
    echo "!! Before running, please carefully review and adjust the configuration variables at the top of the script to match your environment !!"
    exit 1
fi

# 根据提供的参数执行相应的函数
if [ "$1" == "source" ]; then
    run_on_source_host
elif [ "$1" == "target" ]; then
    run_on_target_host
else
    error "Invalid argument: '$1'. Use 'source' or 'target'."
fi 