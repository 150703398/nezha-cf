# 使用 Debian 系官方 Node 镜像
FROM node:18-bullseye-slim

WORKDIR /app

# 安装构建依赖
RUN apt-get update && \
    apt-get install -y build-essential python3 curl git && \
    rm -rf /var/lib/apt/lists/*

# 复制 package.json & package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制项目文件
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
