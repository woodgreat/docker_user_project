#!/bin/bash
# fix_sh.sh - Fix shell script line endings and permissions
# Converts Windows CRLF (\r\n) to Linux LF (\n)
# Adds execute permission (+x) to all .sh files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Fixing shell scripts in: $SCRIPT_DIR"
echo "=========================================="

# Find all .sh files
sh_files=("$SCRIPT_DIR"/*.sh)

if [ ${#sh_files[@]} -eq 0 ]; then
    echo "No .sh files found!"
    exit 0
fi

count=0
for sh_file in "${sh_files[@]}"; do
    [ -e "$sh_file" ] || continue
    
    echo -e "\nProcessing: $(basename "$sh_file")"
    
    # Fix line endings: Windows CRLF -> Linux LF
    if sed -i 's/\r$//' "$sh_file" 2>/dev/null; then
        echo "  ✓ Line endings fixed (CRLF → LF)"
    else
        echo "  ⚠ Line endings fix skipped or already OK"
    fi
    
    # Add execute permission
    if chmod +x "$sh_file" 2>/dev/null; then
        echo "  ✓ Execute permission set (+x)"
    else
        echo "  ✗ Failed to set execute permission"
    fi
    
    count=$((count + 1))
done

echo -e "\n=========================================="
echo "Done! Processed $count shell script(s)."
echo "=========================================="
