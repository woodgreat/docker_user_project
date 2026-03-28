# Docker Universal Project Template

## Directory Structure
```
./docker_project
├── docker_work_dir/
│   ├── config.json         # Config file (shared by all scripts)
│   ├── Dockerfile          # Image build file
│   ├── install_docker.sh   # Build image (required first run)
│   ├── start.sh            # Start container (start only, no build)
│   ├── halt.sh             # Stop container (stop only, no delete)
│   ├── delete.sh           # Delete stopped container (use with caution)
│   ├── exec.sh             # Enter container
│   ├── list.sh             # List all Docker containers
│   └── docker_work_dir.md  # This documentation
└── workspace/              # Shared directory between host and container (auto-created)
```

## Prerequisites

Requires `jq` tool (for parsing JSON config files):
```bash
sudo apt-get install jq
```

## Config File (config.json)

All configurable items are here, scripts read automatically:

```json
{
  "image_name": "docker_user_image_name",      # Image name
  "container_name": "docker_user_container_name", # Container name
  "workspace_dir": "../workspace",        # Host shared directory (relative path)
  "container_workspace": "/workspace"     # Container mount point
}
```

**Just modify this to adapt to different projects!**

## Script Usage

| Script | Purpose | Description |
|--------|---------|-------------|
| `./install_docker.sh` | Build image | **Required first**, auto-renames on success to prevent accidental runs |
| `./start.sh` | Start container | Start only, no build (fails if image not found) |
| `./halt.sh` | Stop container | Stop only, no delete, data preserved |
| `./delete.sh` | Delete container | Delete stopped container (use with caution) |
| `./exec.sh` | Enter container | Enters bash if container is running |
| `./list.sh` | List containers | Lists all Docker containers (running + stopped) |

## Usage Workflow

### Normal Usage (Recommended)
```bash
# 0. List all container status (optional)
./list.sh

# 1. Build image first (required, re-run if Dockerfile changes)
#    Note: On success, script auto-renames to install_docker.sh__done to prevent accidents
./install_docker.sh

# 2. Then start container
./start.sh

# 3. Enter container to work
./exec.sh

# 4. Stop when done (data preserved)
./halt.sh

# 5. Check status again (optional)
./list.sh
```

### Rebuilding Image
If Dockerfile changes and you need to rebuild:
```bash
# 1. Rename script back
mv install_docker.sh__done install_docker.sh

# 2. Rebuild
./install_docker.sh
```

## Important Notes

⚠️ **Containers are temporary, data is persistent!**

- Work inside container should be placed in configured `container_workspace` directory (default `/workspace`)
- Data automatically syncs to host `workspace_dir` (default `../workspace`)
- After container deletion, data in shared directory is NOT lost!

## Docker Registry Mirror Config (Alibaba Cloud Only)

If on Alibaba Cloud machine, recommended config:

```bash
# Create/modify config file
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://your-accelerator-id.mirror.aliyuncs.com"],
  "features": { "buildkit": false }
}
EOF


suggest:
  https://vltrspxd.mirror.aliyuncs.com



# Restart Docker (important!)
sudo systemctl daemon-reload
sudo systemctl restart docker

# Verify
docker info | grep -A10 "Registry Mirrors:"
```

## How to Reuse This Template

1. Copy entire `docker_project` folder to new project
2. Modify config in `docker_work_dir/config.json` (image name, container name, etc.)
3. Modify `docker_work_dir/Dockerfile` to customize your image
4. Start using!


## Notice !
  Don't forget give rights to scripts use:
```bash
  chmod +x *.sh
```  
  
---
Created: 2026-03-14
Template authors: longxiaoxia & wood
