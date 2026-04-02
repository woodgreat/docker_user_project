# Docker Universal Project Template (Sword / 宝剑)

**Sword (宝剑)** 是一个通用的 Docker 应用开发框架模板，帮助开发者快速搭建基于 Docker 的容器化开发环境。

Sword (宝剑) is a universal Docker application development framework template that helps developers quickly build a containerized development environment based on Docker.

### 🎯 核心逻辑 / Core Logic
简易配置 • 脚本一键 • 数据持久化 • 灵活复用

Easy Config • One-click Scripts • Data Persistence • Flexible Reuse

### 📋 目录结构 / Directory Structure
```
./docker_user_project
├── docker_work_dir/
│   ├── config.json         # 配置文件（所有脚本共享）/ Config file (shared by all scripts)
│   ├── Dockerfile          # 镜像构建文件 / Image build file
│   ├── fix_sh.sh           # 修复脚本：换行符+权限 / Fix shell scripts: line endings + permissions
│   ├── install_docker.sh   # 构建镜像（首次运行必需）/ Build image (required first run)
│   ├── start.sh            # 启动容器（仅启动，不构建）/ Start container (start only, no build)
│   ├── halt.sh             # 停止容器（仅停止，不删除）/ Stop container (stop only, no delete)
│   ├── delete.sh           # 删除已停止容器（谨慎使用）/ Delete stopped container (use with caution)
│   ├── exec.sh             # 进入容器 / Enter container
│   ├── list.sh             # 列出所有 Docker 容器 / List all Docker containers
│   └── docker_work_dir.md  # 详细文档 / Detailed documentation
└── workspace/              # 主机与容器共享目录（自动创建）/ Shared directory between host and container (auto-created)
```

### 📦 前置依赖 / Prerequisites

需要 `jq` 工具（用于解析 JSON 配置文件）:
Requires `jq` tool (for parsing JSON config files):
```bash
sudo apt-get install jq
```

### ⚙️ 配置文件 (config.json) / Config File (config.json)

所有可配置项都在这里，脚本自动读取：

All configurable items are here, scripts read automatically:

```json
{
  "image_name": "docker_user_image_name",      # 镜像名称 / Image name
  "container_name": "docker_user_container_name", # 容器名称 / Container name
  "workspace_dir": "../workspace",        # 主机共享目录（相对路径）/ Host shared directory (relative path)
  "container_workspace": "/workspace"     # 容器挂载点 / Container mount point
}
```

**只需修改此处即可适配不同项目！**

**Just modify this to adapt to different projects!**

### 📜 脚本使用 / Script Usage

| 脚本 / Script | 用途 / Purpose | 说明 / Description |
|--------|---------|-------------|
| `./fix_sh.sh` | 修复脚本 / Fix scripts | 修复换行符（Windows CRLF → Linux LF）+ 设置执行权限（+x）/ Fix line endings + set execute permissions |
| `./install_docker.sh` | 构建镜像 / Build image | **首次必需**，成功后自动重命名防止意外运行 / **Required first**, auto-renames on success to prevent accidental runs |
| `./start.sh` | 启动容器 / Start container | 仅启动，不构建（镜像不存在则失败）/ Start only, no build (fails if image not found) |
| `./halt.sh` | 停止容器 / Stop container | 仅停止，不删除，数据保留 / Stop only, no delete, data preserved |
| `./delete.sh` | 删除容器 / Delete container | 删除已停止容器（谨慎使用）/ Delete stopped container (use with caution) |
| `./exec.sh` | 进入容器 / Enter container | 容器运行时进入 bash / Enters bash if container is running |
| `./list.sh` | 列出容器 / List containers | 列出所有 Docker 容器（运行中+已停止）/ Lists all Docker containers (running + stopped) |

### 🔄 使用流程 / Usage Workflow

#### 正常使用（推荐）/ Normal Usage (Recommended)
```bash
# 0. 先修复脚本（换行符+权限）/ Fix shell scripts first (line endings + permissions)
./fix_sh.sh

# 1. 列出所有容器状态（可选）/ List all container status (optional)
./list.sh

# 2. 首先构建镜像（必需，如果 Dockerfile 修改需要重新运行）
#    Build image first (required, re-run if Dockerfile changes)
#    注意：成功后脚本自动重命名为 install_docker.sh__done 防止意外
#    Note: On success, script auto-renames to install_docker.sh__done to prevent accidents
./install_docker.sh

# 2. 然后启动容器 / Then start container
./start.sh

# 3. 进入容器工作 / Enter container to work
./exec.sh

# 4. 完成后停止（数据保留）/ Stop when done (data preserved)
./halt.sh

# 5. 再次检查状态（可选）/ Check status again (optional)
./list.sh
```

#### 重新构建镜像 / Rebuilding Image
如果 Dockerfile 修改，需要重新构建：
If Dockerfile changes and you need to rebuild:
```bash
# 1. 将脚本改回原名 / Rename script back
mv install_docker.sh__done install_docker.sh

# 2. 重新构建 / Rebuild
./install_docker.sh
```

### ⚠️ 重要提示 / Important Notes

⚠️ **容器是临时的，数据是持久的！** / **Containers are temporary, data is persistent!**

- 容器内工作应放在配置好的 `container_workspace` 目录（默认 `/workspace`）
- Work inside container should be placed in configured `container_workspace` directory (default `/workspace`)
- 数据自动同步到主机的 `workspace_dir`（默认 `../workspace`）
- Data automatically syncs to host `workspace_dir` (default `../workspace`)
- 删除容器后，共享目录中的数据**不会丢失**！
- After container deletion, data in shared directory is **NOT lost!**

### 🚀 Docker 镜像加速器配置（仅阿里云）/ Docker Registry Mirror Config (Alibaba Cloud Only)

如果使用阿里云服务器，推荐配置：

If on Alibaba Cloud machine, recommended config:

```bash
# 创建/修改配置文件 / Create/modify config file
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://your-accelerator-id.mirror.aliyuncs.com"],
  "features": { "buildkit": false }
}
EOF
```

建议使用：
suggest:
  https://vltrspxd.mirror.aliyuncs.com

```bash
# 重启 Docker（重要！）/ Restart Docker (important!)
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证 / Verify
docker info | grep -A10 "Registry Mirrors:"
```

### 🔁 如何复用此模板 / How to Reuse This Template

1. 将整个 `docker_user_project` 文件夹复制到新项目 / Copy entire `docker_user_project` folder to new project
2. 修改 `docker_work_dir/config.json` 中的配置（镜像名称、容器名称等）/ Modify config in `docker_work_dir/config.json` (image name, container name, etc.)
3. 修改 `docker_work_dir/Dockerfile` 来自定义镜像 / Modify `docker_work_dir/Dockerfile` to customize your image
4. 开始使用！/ Start using!

### 📝 注意事项 / Notice

不要忘记给脚本添加执行权限：
Don't forget give execution rights to scripts:
```bash
  chmod +x *.sh
```

## 开源许可 / License

本项目采用 MIT 协议，可自由使用、修改、分发。

This project is licensed under the MIT License, can be freely used, modified, and distributed.

## 贡献 / Contributing

欢迎提交 Issue 或 Pull Request 改进此框架。

Welcome to submit Issues or Pull Requests to improve this framework.

<p align="center">
  <img src="etc/wood_logo.jpg" alt="Sword Docker Template" width="200"><br>
  <em>开源免费 • MIT 协议 / Open source • MIT License<br>Wood logo 是 Wood 项目的标识 / Wood logo is the trademark of Wood projects</em>
</p>