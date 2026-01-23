# 使用官方的 Bash 镜像作为基础镜像
FROM debian:bullseye-slim

# 安装 Docker、curl 和必要的依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    docker.io \
    git \
    bash \
    && rm -rf /var/lib/apt/lists/*

# 将安装脚本复制到容器内
COPY install_nezha_cf_tunnel.sh /opt/

# 设置工作目录
WORKDIR /opt

# 给脚本添加执行权限
RUN chmod +x install_nezha_cf_tunnel.sh

# 默认执行安装脚本
ENTRYPOINT ["./install_nezha_cf_tunnel.sh"]
