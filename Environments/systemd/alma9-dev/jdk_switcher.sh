#!/bin/bash
set -e

switch_jdk() {
    local version=$1
    local jdk_path="/usr/lib/jvm/java-${version}-openjdk-amd64"

    if [ ! -d "${jdk_path}" ]; then
        echo "错误: JDK 版本 ${version} 未找到或未安装在 ${jdk_path}" >&2
        return 1
    fi

    echo "设置 Java alternatives 指向 JDK ${version}..."
    update-alternatives --set java "${jdk_path}/bin/java" || echo "警告: 设置 java alternative 失败"
    update-alternatives --set javac "${jdk_path}/bin/javac" || echo "警告: 设置 javac alternative 失败"
    update-alternatives --set jar "${jdk_path}/bin/jar" || echo "警告: 设置 jar alternative 失败"
    update-alternatives --set javadoc "${jdk_path}/bin/javadoc" || echo "警告: 设置 javadoc alternative 失败"

    echo "设置 JAVA_HOME=${jdk_path}"
    export JAVA_HOME="${jdk_path}"
    export PATH="$JAVA_HOME/bin:$(echo $PATH | sed -e "s#$JAVA_HOME/bin:##g" -e "s#:/usr/lib/jvm/java-[0-9]*-openjdk-amd64/bin##g")"

    echo "已切换到 JDK ${version}"
    echo "当前版本:"
    java -version
}

show_usage() {
    echo "用法: source jdk [版本] 或 jdk [版本]"
    echo "可用版本: 8, 11, 17"
    echo "运行 'source jdk <版本>' 来在当前 shell 设置 JAVA_HOME 和 PATH。"
    echo ""
    echo "当前配置 (alternatives):"
    update-alternatives --display java | head -n 1
    echo "当前 JAVA_HOME: ${JAVA_HOME:-未设置}"
    echo "当前 'java -version':"
    if command -v java &> /dev/null; then
        java -version
    else
        echo "  'java' 命令未找到"
    fi
}

if [ -z "$1" ]; then
    show_usage
    exit 0
fi

case "$1" in
  8|11|17)
    switch_jdk "$1"
    echo "请注意：直接运行此脚本不会修改当前 Shell 的环境变量。"
    echo "请使用 'source jdk $1' 或对应的别名 (jdk8, jdk11, jdk17) 来更新环境。"
    ;;
  *)
    show_usage
    exit 1
    ;;
esac
