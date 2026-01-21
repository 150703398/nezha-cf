# Nezha + Cloudflare Tunnel 一键部署脚本

📦 本仓库提供一个 **Bash 脚本**，用于在 Linux 系统上通过 Docker 一键部署：

- **Nezha Dashboard**（内网监控与管理）
- **Cloudflare Tunnel（Token 模式）**，将 Nezha Dashboard 安全暴露到公网

该方案结合了 **Nezha 监控** 和 **Cloudflare Tunnel 隧道**，实现快速、稳定、无需公网 IP 的远程访问。

---

## 功能介绍

### 1️⃣ 基本功能

- 自动创建工作目录 `/opt/nezha-cf-tunnel`
- 清理旧容器，保证每次部署干净
- 启动 Nezha Dashboard 容器：
  - Docker 镜像：`ghcr.io/nezhahq/nezha:v1.14.14`
  - 内部端口：`8008`
  - 本地绑定：`127.0.0.1:$LOCAL_PORT`（默认 8008）
- 启动 Cloudflare Tunnel 容器：
  - Docker 镜像：`cloudflare/cloudflared:latest`
  - 使用 **Tunnel Token** 模式（无需手动登录 Cloudflare）
  - 自动将本地 Nezha Dashboard 暴露到公网
- 自检容器状态及日志输出，方便排查问题

#### 使用说明
 1️⃣ 准备工作

 已安装 Docker（建议 Docker 20+）

  拥有 Cloudflare 账户和 Tunnel Token（可在 Cloudflare Zero Trust
  获取）

 Linux 系统（Ubuntu/Debian/CentOS 等）

 2️⃣ 配置脚本

编辑 deploy.sh：

DOMAIN="你的域名"       # 你的域名

LOCAL_PORT=8008                 # Dashboard 内网端口

TUNNEL_TOKEN="在这里粘贴你从 Cloudflare 拿到的 Token"


❗ 注意：请替换 TUNNEL_TOKEN 为真实值，否则脚本会报错退出。

3️⃣ 运行脚本
chmod +x deploy.sh

./deploy.sh


脚本会自动拉取 Docker 镜像并启动容器

部署完成后，访问 https://<你的域名> 即可访问 Nezha Dashboard

🚀 特性

自动化：无需手动配置 Docker 和 Cloudflare Tunnel

安全：Dashboard 仅本地访问，公网通过 Cloudflare 隧道

稳定：使用 Token 模式，避免账号登录问题

自检：自动打印容器状态和日志，方便排错

⚠️ 注意事项

脚本使用 --network host 模式运行 Cloudflared，确保系统端口未被占用

脚本默认使用内网端口 8008，可根据需要修改

需提前生成 Cloudflare Tunnel Token

适合 Linux 系统，不推荐在 Windows 直接执行

📝 镜像版本

Nezha Dashboard：ghcr.io/nezhahq/nezha:v1.14.14

Cloudflared：cloudflare/cloudflared:latest

 
