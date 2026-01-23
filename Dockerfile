# 使用官方的 Node.js 镜像作为基础镜像
FROM node:16

# 设置工作目录
WORKDIR /app

# 安装构建工具，防止某些 npm 包需要编译时出错
RUN apt-get update && apt-get install -y \
  build-essential \
  python3 \
  && rm -rf /var/lib/apt/lists/*

# 将本地的 package.json 和 package-lock.json 复制到容器中
COPY package*.json ./

# 使用 npm ci 安装依赖
RUN npm ci --only=production

# 将项目的所有文件复制到容器中
COPY . .

# 暴露容器端口
EXPOSE 3000

# 启动应用
CMD ["npm", "start"]
