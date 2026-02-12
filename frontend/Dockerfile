FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
COPY .env.production .env
RUN rm -rf ./dist/* && npm run build

RUN npm install -g serve

EXPOSE 10001
CMD ["serve", "-s", "dist", "-l", "10001", "--no-clipboard"]
