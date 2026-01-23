# 使用官方的 Node.js 镜像作为基础镜像
FROM node:16

# 设置工作目录
WORKDIR /app

# 将本地的 package.json 和 package-lock.json 复制到容器中
COPY package*.json ./

# 安装依赖
RUN npm install

# 将项目的所有文件复制到容器中
COPY . .

# 暴露容器端口
EXPOSE 3000

# 启动应用
CMD ["npm", "start"]
