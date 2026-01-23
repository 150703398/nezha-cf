# 使用官方 Node.js 镜像，选择合适的版本（根据项目需求选择版本）
FROM node:18-bullseye-slim

# 设置工作目录
WORKDIR /app

# 安装构建依赖
RUN apt-get update && \
    apt-get install -y build-essential python3 git curl && \
    rm -rf /var/lib/apt/lists/*

# 设置 npm registry 为淘宝源，避免网络问题
RUN npm config set registry https://registry.npmjs.org/

# 复制 package.json 和 package-lock.json 文件
COPY package*.json ./

# 安装依赖（使用 npm ci 来确保安装一致性）
RUN npm ci --only=production

# 复制整个项目代码
COPY . .

# 暴露容器端口
EXPOSE 3000

# 启动命令（替换为你的项目启动命令）
CMD ["npm", "start"]
