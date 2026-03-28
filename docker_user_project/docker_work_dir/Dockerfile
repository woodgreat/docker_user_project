# 基础镜像：Ubuntu latest version
FROM ubuntu:latest

# 更新包管理器
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 启动时保持容器运行
CMD ["sleep", "infinity"]
