#!/bin/bash

echo "Starting bench-test Development Environment..."

# 检查镜像是否存在
echo "Checking if docker image exists..."
if docker images | grep -q "shuai/bench-test"; then
    echo "Error: Docker image 'shuai/bench-test' not found."
    echo "Please build the image first using: docker build -t shuai/bench-test ."
    exit 1
fi

echo "Docker image found, proceeding with container startup..."

# 启动容器
if docker-compose up -d; then
    echo "Waiting for SSH service..."
    sleep 2
    
    echo "Container started successfully. SSH connection info:"
    echo "  Host: localhost"
    echo "  Port: 28960"
    echo "  User: shijiashuai"
    echo "  Password: phoenix2024"
    echo ""
    echo "Connect using: ssh -p 28960 shijiashuai@localhost"
else
    echo "Failed to start container"
    exit 1
fi 
