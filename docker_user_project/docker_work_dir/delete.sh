#!/bin/bash
# Docker project delete script (universal template - delete stopped container only)

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

echo "Deleting container..."
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "Container deleted!"
