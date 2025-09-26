# 使用 Node 16 作为基础镜像
FROM node:16-bullseye

# 设置工作目录
WORKDIR /usr/src/app

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm install --save

# 复制所有代码
COPY . .

# 暴露应用端口（默认 Express 用 8080 或 3000）
EXPOSE 3000

# 启动应用
CMD ["npm", "start"]
