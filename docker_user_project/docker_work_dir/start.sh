#!/bin/bash
# Docker project start script (universal template - start only, no build)

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read config file
CONFIG_FILE="$SCRIPT_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config file $CONFIG_FILE not found"
    exit 1
fi

# Read constants from config
IMAGE_NAME="$(jq -r '.image_name' "$CONFIG_FILE")"
CONTAINER_NAME="$(jq -r '.container_name' "$CONFIG_FILE")"
WORKSPACE_DIR="$(jq -r '.workspace_dir' "$CONFIG_FILE")"
CONTAINER_WORKSPACE="$(jq -r '.container_workspace' "$CONFIG_FILE")"

# Convert to absolute path - simpler and more robust way
FULL_WORKSPACE_DIR="$SCRIPT_DIR/$WORKSPACE_DIR"
# Normalize path (remove ../)
FULL_WORKSPACE_DIR="$(readlink -f "$FULL_WORKSPACE_DIR")"

# Check if image exists
if [ "$(docker images -q "$IMAGE_NAME" 2>/dev/null)" = "" ]; then
    echo "Error: image $IMAGE_NAME not found!"
    echo "Please run first: $SCRIPT_DIR/install_docker.sh"
    exit 1
fi

# Check if container exists
if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    # Container exists
    if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
        # Container is already running, skip
        echo "✓ Container $CONTAINER_NAME is already running, skipping creation."
    else
        # Container is stopped, start it
        echo "Container $CONTAINER_NAME exists, starting..."
        docker start "$CONTAINER_NAME"
    fi
else
    # Container doesn't exist, create and start
    echo "Container doesn't exist, creating new container..."
    
    # Ensure shared directory exists
    mkdir -p "$FULL_WORKSPACE_DIR"
    
    # Start new container
    echo "Starting new container..."
    docker run -d \
      --name "$CONTAINER_NAME" \
      -v "$FULL_WORKSPACE_DIR:$CONTAINER_WORKSPACE" \
      -v /etc/localtime:/etc/localtime:ro \
      "$IMAGE_NAME"
fi

echo ""
echo "Container started/ready!"
echo "Enter container command: $SCRIPT_DIR/exec.sh"
