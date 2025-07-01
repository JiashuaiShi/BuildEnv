#!/bin/bash
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

# Create the shared directory if it doesn't exist
mkdir -p ./share

docker-compose up -d
