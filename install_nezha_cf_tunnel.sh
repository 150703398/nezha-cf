#!/usr/bin/env bash
set -e

############################################
# 用户可修改区
############################################
NEZHA_DOMAIN="nezha.example.com"
CF_TUNNEL_TOKEN="替换成你的Cloudflare_Tunnel_Token"
NEZHA_IMAGE="ghcr.io/nezhahq/nezha:v1.14.14"
WORKDIR="/opt/nezha-tunnel"

############################################
# 基础检查
############################################
if [[ $EUID -ne 0 ]]; then
  echo "请使用 root 运行"
  exit 1
fi

echo "[+] 开始部署 Nezha + Cloudflare Tunnel（方案3）"

############################################
# 安装 Docker（如未安装）
############################################
if ! command -v docker &>/dev/null; then
  echo "[+] 安装 Docker..."
  curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker compose &>/dev/null; then
  echo "[+] 安装 docker-compose-plugin..."
  mkdir -p /usr/local/lib/docker/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

############################################
# 创建目录
############################################
mkdir -p ${WORKDIR}
cd ${WORKDIR}

############################################
# 生成 docker-compose.yml
############################################
cat > docker-compose.yml <<EOF
services:
  nezha-dashboard:
    image: ${NEZHA_IMAGE}
    container_name: nezha-dashboard
    restart: unless-stopped
    networks:
      - nezha_net

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: nezha-cloudflared
    restart: unless-stopped
    command: tunnel run
    environment:
      - TUNNEL_TOKEN=${CF_TUNNEL_TOKEN}
    networks:
      - nezha_net

networks:
  nezha_net:
    driver: bridge
EOF

############################################
# 启动服务
############################################
docker compose up -d

############################################
# 输出信息
############################################
echo "========================================"
echo "🎉 部署完成"
echo ""
echo "🌐 面板访问地址："
echo "   https://${NEZHA_DOMAIN}"
echo ""
echo "🔒 安全特性："
echo " - 无公网端口暴露"
echo " - 仅 Cloudflare Tunnel 可访问"
echo " - VPS 扫描不到任何服务"
echo ""
echo "📦 容器状态："
docker ps
echo "========================================"
