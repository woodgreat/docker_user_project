#!/bin/bash
# Docker project enter container script (universal template)

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read config file
CONFIG_FILE="$SCRIPT_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config file $CONFIG_FILE not found"
    exit 1
fi

# Read constants from config
CONTAINER_NAME="$(jq -r '.container_name' "$CONFIG_FILE")"

# Check if container is running
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Entering container $CONTAINER_NAME..."
    docker exec -it "$CONTAINER_NAME" bash
else
    echo "Container $CONTAINER_NAME is not running!"
    echo "Please run first: $SCRIPT_DIR/start.sh"
fi
