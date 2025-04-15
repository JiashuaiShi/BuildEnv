#!/bin/bash

echo "Starting Ubuntu 24.04 Development Environment..."

# 检查容器是否已构建
if docker images | grep -q "shuai/ubuntu-2404:latest"; then
    echo "Error: Container image not found. Please run ./build.sh first"
    exit 1
fi

# 启动容器
if docker-compose up -d; then
    echo "Waiting for SSH service..."
    sleep 2
    
    echo "Container started successfully. SSH connection info:"
    echo "  Host: localhost"
    echo "  Port: 28964"
    echo "  User: shijiashuai"
    echo "  Password: phoenix2024"
    echo ""
    echo "Connect using: ssh -p 28964 shijiashuai@localhost"
else
    echo "Failed to start container"
    exit 1
fi 
