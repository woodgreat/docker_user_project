#!/bin/bash
# Docker project list script (universal template - list all containers)

echo "=== Docker Container List ==="
echo ""

# Table header
printf "%-20s %-10s %-20s %-30s\n" "NAME" "STATUS" "IMAGE" "CREATED"
printf "%-20s %-10s %-20s %-30s\n" "--------" "----" "----" "--------"

# List all containers (including stopped ones)
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.CreatedAt}}" | tail -n +2 | while read -r line; do
    # Format output
    NAME=$(echo "$line" | awk '{print $1}')
    STATUS=$(echo "$line" | awk '{print $2, $3, $4}' | sed 's/ *$//')
    IMAGE=$(echo "$line" | awk '{print $5}')
    CREATED=$(echo "$line" | awk '{print $6, $7, $8, $9}' | sed 's/ *$//')
    
    printf "%-20s %-10s %-20s %-30s\n" "$NAME" "$STATUS" "$IMAGE" "$CREATED"
done

echo ""
echo "=== Quick Commands ==="
echo "Start container:  ./start.sh"
echo "Stop container:   ./halt.sh"
echo "Enter container:  ./exec.sh"
echo "Delete container: ./delete.sh"
