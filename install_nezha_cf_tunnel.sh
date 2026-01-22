#!/bin/bash
set -e

# =========================
# 🟢 配置参数
# =========================
INSTALL_DIR="/opt/nezha-cf-tunnel"
DASHBOARD_IMAGE="ghcr.io/nezhahq/nezha:v1.14.14"
CLOUDFLARE_IMAGE="cloudflare/cloudflared:latest"
ARGO_TOKEN=""  # <-- 填入你的隧道令牌TOKEN
HOSTNAME=""     # 固定隧道域名
HOST_PORT=5555   # VPS 公网端口映射到 Dashboard 内部端口
SECRET_LENGTH=32

# =========================
# 📂 创建安装目录
# =========================
mkdir -p "$INSTALL_DIR"/{data,cert}
cd "$INSTALL_DIR"

# =========================
# 🔑 生成 Dashboard secret
# =========================
NZ_CLIENT_SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c $SECRET_LENGTH)
echo "生成 NZ_CLIENT_SECRET: $NZ_CLIENT_SECRET"

# =========================
# 🐳 清理旧容器
# =========================
docker rm -f nezha-dashboard nezha-cloudflared >/dev/null 2>&1 || true

# =========================
# 📄 创建 docker-compose.yml
# =========================
cat > docker-compose.yml <<EOF
version: '3'
services:
  nezha-dashboard:
    image: $DASHBOARD_IMAGE
    container_name: nezha-dashboard
    restart: unless-stopped
    environment:
      - NZ_DB_PATH=/data/nezha.db
      - NZ_CLIENT_SECRET=$NZ_CLIENT_SECRET
      - NZ_LISTEN_PORT=8008
    ports:
      - "$HOST_PORT:8008"
    volumes:
      - ./data:/data
  nezha-cloudflared:
    image: $CLOUDFLARE_IMAGE
    container_name: nezha-cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run --token "$ARGO_TOKEN"
    depends_on:
      - nezha-dashboard
EOF

# =========================
# 🚀 启动服务
# =========================
docker-compose up -d

# =========================
# 🔍 自检 Dashboard (使用内部 curl)
# =========================
sleep 5
if docker exec nezha-dashboard sh -c "wget -qO- http://127.0.0.1:8008/ | grep -q 'Nezha'" ; then
    DASHBOARD_OK="yes"
else
    DASHBOARD_OK="no"
fi

# =========================
# 📄 输出信息
# =========================
echo "=============================="
echo "🎉 部署完成！"
echo "🌐 Dashboard 访问地址 (Cloudflare Tunnel): https://$HOSTNAME"
echo "🔒 Dashboard 内部端口 (VPS Agent 可访问): $HOST_PORT"
echo "🛡️ NZ_CLIENT_SECRET: $NZ_CLIENT_SECRET"
echo "📌 Dashboard 内部状态自检: $DASHBOARD_OK"
echo "=============================="
echo "📌 VPS Agent 使用示例:"
echo "export NZ_SERVER=http://<VPS_IP>:$HOST_PORT"
echo "export NZ_CLIENT_SECRET=$NZ_CLIENT_SECRET"
echo "nohup ./nezha-agent_linux_amd64 &"
