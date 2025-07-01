#!/bin/bash
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

# Build the base image if it doesn't exist
if [[ "$(docker images -q nas-base:latest 2> /dev/null)" == "" ]]; then
    echo "NAS base image not found. Building..."
    docker build \
        --build-arg DEV_PASSWORD=${DEV_PASSWORD} \
        -t nas-base:latest \
        ../base
fi

# Build the development image using docker-compose
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
docker-compose build
