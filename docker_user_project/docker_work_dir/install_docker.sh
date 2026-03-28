#!/bin/bash
# Docker project build script (universal template - build image only)

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed!"
    exit 1
fi

# Check if jq is installed, try to install automatically on Debian/Ubuntu
if ! command -v jq &> /dev/null; then
    echo "Warning: jq is not installed, trying to install automatically..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y jq
        if [ $? -ne 0 ]; then
            echo "Error: failed to install jq automatically, please install manually"
            echo "For Debian/Ubuntu: sudo apt-get install jq"
            echo "For CentOS/RHEL: sudo yum install jq"
            echo "For macOS: brew install jq"
            exit 1
        fi
    else
        echo "Error: jq is required but not installed, please install manually:"
        echo "For Debian/Ubuntu: sudo apt-get install jq"
        echo "For CentOS/RHEL: sudo yum install jq"
        echo "For macOS: brew install jq"
        exit 1
    fi
fi

# Auto add execution permissions to all scripts
echo "Adding execution permissions to all *.sh scripts..."
chmod +x "$SCRIPT_DIR"/*.sh

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# Read config file
CONFIG_FILE="$SCRIPT_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config file $CONFIG_FILE not found"
    exit 1
fi

# Default values (for detecting if user needs to be prompted)
DEFAULT_IMAGE_NAME="docker_user_image_name"
DEFAULT_CONTAINER_NAME="docker_user_container_name"

# Read current config
CURRENT_IMAGE_NAME="$(jq -r '.image_name' "$CONFIG_FILE")"
CURRENT_CONTAINER_NAME="$(jq -r '.container_name' "$CONFIG_FILE")"

# Check and prompt for image_name
if [ "$CURRENT_IMAGE_NAME" = "$DEFAULT_IMAGE_NAME" ] || [ -z "$CURRENT_IMAGE_NAME" ]; then
    echo "Current image name is default: $CURRENT_IMAGE_NAME"
    read -p "Enter new image name (press Enter to keep default): " NEW_IMAGE_NAME
    if [ -n "$NEW_IMAGE_NAME" ]; then
        CURRENT_IMAGE_NAME="$NEW_IMAGE_NAME"
        # Update config.json
        jq ".image_name = \"$CURRENT_IMAGE_NAME\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
fi

# Check and prompt for container_name
if [ "$CURRENT_CONTAINER_NAME" = "$DEFAULT_CONTAINER_NAME" ] || [ -z "$CURRENT_CONTAINER_NAME" ]; then
    echo "Current container name is default: $CURRENT_CONTAINER_NAME"
    read -p "Enter new container name (press Enter to keep default): " NEW_CONTAINER_NAME
    if [ -n "$NEW_CONTAINER_NAME" ]; then
        CURRENT_CONTAINER_NAME="$NEW_CONTAINER_NAME"
        # Update config.json
        jq ".container_name = \"$CURRENT_CONTAINER_NAME\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
fi

echo "Building Docker image: $CURRENT_IMAGE_NAME"
docker build -t "$CURRENT_IMAGE_NAME" "$SCRIPT_DIR"

if [ $? -eq 0 ]; then
    echo "Image built successfully!"
    
    # After successful build, auto-rename to prevent accidental runs
    DONE_SCRIPT="$SCRIPT_DIR/${SCRIPT_NAME}__done"
    if [ -f "$DONE_SCRIPT" ]; then
        echo "Warning: $DONE_SCRIPT already exists, removing..."
        rm -f "$DONE_SCRIPT"
    fi
    mv "$SCRIPT_PATH" "$DONE_SCRIPT"
    echo "Notice: script has been auto-renamed to ${SCRIPT_NAME}__done to prevent accidental runs"
    echo "        To rebuild, rename ${SCRIPT_NAME}__done back to ${SCRIPT_NAME}"
    
    echo ""
    echo "Start container command: $SCRIPT_DIR/start.sh"
else
    echo "Error: failed to build image!"
    exit 1
fi
