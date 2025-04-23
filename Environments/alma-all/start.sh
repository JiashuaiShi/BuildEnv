#!/bin/bash

echo "Starting AlmaLinux 9 Unified Development Environment..."

# Define image and container names based on docker-compose.yaml
# Assuming image name follows pattern <username>/<service_name>:<tag>
# Or inferred by docker-compose build.
# Let's rely on docker-compose to find the correct image.
CONTAINER_NAME="jiashuai.alma_9"
SERVICE_NAME="alma_9"
SSH_PORT="28974"
USER_ID="2034"
GROUP_ID="2000"

# Check if the container is already running using the service name
if docker-compose ps -q ${SERVICE_NAME} &>/dev/null; then
  if [ "$(docker-compose ps -q ${SERVICE_NAME} | xargs docker inspect -f '{{.State.Status}}')" == "running" ]; then
    echo "Container is already running."
    # Optionally show connection info again or just exit
  fi
fi

# 启动容器
echo "Attempting to start container via docker-compose..."
if docker-compose up -d ${SERVICE_NAME}; then
    echo "Waiting for services inside the container (like SSH)..."
    sleep 5 # Increased sleep time slightly

    # Check container status again
    if [ "$(docker-compose ps -q ${SERVICE_NAME} | xargs docker inspect -f '{{.State.Status}}')" != "running" ]; then
      echo "Container failed to start or stay running. Check logs with:"
      echo "  docker-compose logs ${SERVICE_NAME}"
      echo "  Or ./dev-cli.sh logs"
      exit 1
    fi

    echo "Container started successfully. SSH connection info:"
    echo "  Host: localhost"
    echo "  Port: ${SSH_PORT}"
    echo "  User: Defined in Dockerfile (UID ${USER_ID}, GID ${GROUP_ID})"
    echo "  Password: (Set within Dockerfile/container setup if applicable)"
    echo ""
    echo "Connect example: ssh -p ${SSH_PORT} <username>@localhost"
    # Replace <username> with the actual username configured for UID 2034 inside the container
    echo ""
    echo "Use './dev-cli.sh ssh' for easier connection if configured."

else
    echo "Failed to execute docker-compose up."
    echo "Check docker-compose logs ${SERVICE_NAME} for errors."
    exit 1
fi

# Removed environment specific feature list (JDK, C++, etc.)
# Add relevant info for alma-all environment if needed. 