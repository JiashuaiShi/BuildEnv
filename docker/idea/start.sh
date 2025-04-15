#!/bin/bash

echo "Starting Multi-JDK Development Environment..."

# 检查容器是否已构建
if docker images | grep -q "shuai/idea:latest"; then
    echo "Error: Container image not found. Please run ./build.sh first"
    exit 1
fi

# 启动容器
if docker-compose up -d; then
    echo "Waiting for SSH service..."
    sleep 2
    
    echo "Container started successfully. SSH connection info:"
    echo "  Host: localhost"
    echo "  Port: 28963"
    echo "  User: shijiashuai"
    echo "  Password: phoenix2024"
    echo ""
    echo "Connect using: ssh -p 28963 shijiashuai@localhost"
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
