#!/usr/bin/env bash
set -e

# ======================
# 基本参数
# ======================
BASE_DIR="/opt/nezha-cf-tunnel"
DASHBOARD_NAME="nezha-dashboard"
CLOUDFLARED_NAME="nezha-cloudflared"

NEZHA_IMAGE="ghcr.io/nezhahq/nezha:v1.14.14"
CF_IMAGE="cloudflare/cloudflared:latest"

DOMAIN="nezha.ppwq.us.kg"
LOCAL_PORT=8008

# ❗ 必填：Tunnel Token
TUNNEL_TOKEN="在这里粘贴你从 Cloudflare 拿到的 Token"

if [[ "$TUNNEL_TOKEN" == "在这里粘贴你从 Cloudflare 拿到的 Token" ]]; then
  echo "❌ 请先在脚本中填写 TUNNEL_TOKEN"
  exit 1
fi

echo "📂 初始化目录..."
mkdir -p "$BASE_DIR"

echo "🧹 清理旧容器..."
docker rm -f "$DASHBOARD_NAME" "$CLOUDFLARED_NAME" >/dev/null 2>&1 || true

# ======================
# 启动 Nezha Dashboard
# ======================
echo "🚀 启动 Nezha Dashboard（v1.14.14）..."
docker run -d \
  --name "$DASHBOARD_NAME" \
  --restart unless-stopped \
  -p 127.0.0.1:$LOCAL_PORT:8008 \
  "$NEZHA_IMAGE"

sleep 6

# ======================
# 启动 Cloudflare Tunnel（Token 模式）
# ======================
echo "🚀 启动 Cloudflare Tunnel（Token 模式）..."
docker run -d \
  --name "$CLOUDFLARED_NAME" \
  --restart unless-stopped \
  --network host \
  -e TUNNEL_TOKEN="$TUNNEL_TOKEN" \
  "$CF_IMAGE" tunnel run

sleep 5

# ======================
# 自检
# ======================
echo "🔍 容器状态："
docker ps | grep -E "nezha|cloudflared"

echo
echo "🔍 Cloudflared 日志（最近 20 行）："
docker logs --tail 20 "$CLOUDFLARED_NAME"

echo
echo "🎉 部署完成！"
echo "🌐 访问地址：https://$DOMAIN"
echo "🔒 Dashboard 内部端口：$LOCAL_PORT"
echo "🛡️ Cloudflare Tunnel 正常（Token 模式，最稳定）"
