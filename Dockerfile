FROM node:18-bullseye-slim

WORKDIR /app

# 安装构建依赖
RUN apt-get update && \
    apt-get install -y build-essential python3 git curl && \
    rm -rf /var/lib/apt/lists/*

# 设置 npm registry 避免网络问题
RUN npm config set registry https://registry.npmjs.org/

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制项目代码
COPY . .

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["npm", "start"]
