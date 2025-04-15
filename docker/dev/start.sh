#!/bin/bash

echo "Starting Unified Development Environment..."

# 检查容器是否已构建
if docker images | grep -q "shuai/dev:latest"; then
    echo "Error: Container image not found. Please run ./build.sh first"
    exit 1
fi

# 启动容器
if docker-compose up -d; then
    echo "Waiting for SSH service..."
    sleep 2
    
    echo "Container started successfully. SSH connection info:"
    echo "  Host: localhost"
    echo "  Port: 28962"
    echo "  User: shijiashuai"
    echo "  Password: phoenix2024"
    echo ""
    echo "Connect using: ssh -p 28962 shijiashuai@localhost"
    echo ""
    echo "JDK version management:"
    echo "  Switch to JDK 8: jdk8"
    echo "  Switch to JDK 11: jdk11"
    echo "  Switch to JDK 17: jdk17"
    echo "  Check current version: jdk"
else
    echo "Failed to start container"
    exit 1
fi

echo "开发环境功能:"
echo "  1. C++开发: GCC-13, Clang, CMake, Ninja, GDB, Valgrind 等"
echo "  2. Java开发: 支持JDK 8/11/17, Maven, Gradle"
echo "  3. Python开发: Python 3 + pip + venv"
echo ""
echo "特殊命令:"
echo "  * JDK版本切换: jdk8, jdk11, jdk17"
echo "  * 查看当前JDK版本: jdk" 
